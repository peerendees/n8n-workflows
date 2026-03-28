-- =============================================================================
-- THREEMA N8N DSGVO-KONFORME DATENBANKSTRUKTUR
-- =============================================================================
-- Initialisierungsskript für PostgreSQL mit DSGVO-Compliance

-- Extensions aktivieren
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Separate Schema für n8n (wird automatisch erstellt)
-- Unsere DSGVO-Tabellen in eigenem Schema
CREATE SCHEMA IF NOT EXISTS threema_data;
CREATE SCHEMA IF NOT EXISTS audit_log;

-- =============================================================================
-- BENUTZER- UND KONTAKTDATEN (DSGVO-konform)
-- =============================================================================

-- Haupttabelle für Benutzeridentitäten (pseudonymisiert)
CREATE TABLE threema_data.users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    threema_id VARCHAR(8) NOT NULL UNIQUE, -- Threema-ID (z.B. ABCD1234)
    pseudonym_hash VARCHAR(64) NOT NULL UNIQUE, -- SHA-256 Hash für Pseudonymisierung
    consent_given BOOLEAN NOT NULL DEFAULT false,
    consent_timestamp TIMESTAMP WITH TIME ZONE,
    consent_version VARCHAR(10) DEFAULT '1.0',
    data_retention_until TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN DEFAULT false,
    deleted_at TIMESTAMP WITH TIME ZONE
);

-- Verschlüsselte Benutzerdaten (nur bei expliziter Einwilligung)
CREATE TABLE threema_data.user_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES threema_data.users(id) ON DELETE CASCADE,
    encrypted_data TEXT, -- PGP-verschlüsselte Profildaten
    data_type VARCHAR(50) NOT NULL, -- 'profile', 'preferences', etc.
    purpose VARCHAR(100) NOT NULL, -- Zweck der Datenverarbeitung
    legal_basis VARCHAR(50) NOT NULL, -- Rechtsgrundlage (Art. 6 DSGVO)
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =============================================================================
-- NACHRICHTEN UND KONVERSATIONEN
-- =============================================================================

-- Konversationen (Sitzungen)
CREATE TABLE threema_data.conversations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES threema_data.users(id) ON DELETE CASCADE,
    session_hash VARCHAR(64) NOT NULL, -- Anonymisierte Session-ID
    started_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_activity TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    ended_at TIMESTAMP WITH TIME ZONE,
    message_count INTEGER DEFAULT 0,
    retention_until TIMESTAMP WITH TIME ZONE NOT NULL
);

-- Nachrichten (anonymisiert/pseudonymisiert)
CREATE TABLE threema_data.messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    conversation_id UUID NOT NULL REFERENCES threema_data.conversations(id) ON DELETE CASCADE,
    direction VARCHAR(10) NOT NULL CHECK (direction IN ('inbound', 'outbound')),
    message_hash VARCHAR(64) NOT NULL, -- Hash der ursprünglichen Nachricht
    encrypted_content TEXT, -- Verschlüsselter Nachrichteninhalt
    content_type VARCHAR(50) DEFAULT 'text',
    processed_by_ai BOOLEAN DEFAULT false,
    ai_model_version VARCHAR(50),
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    retention_until TIMESTAMP WITH TIME ZONE NOT NULL
);

-- =============================================================================
-- AI-VERARBEITUNG UND LANGCHAIN-DATEN
-- =============================================================================

-- AI-Modell-Interaktionen
CREATE TABLE threema_data.ai_interactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    message_id UUID REFERENCES threema_data.messages(id) ON DELETE CASCADE,
    model_name VARCHAR(100) NOT NULL,
    model_version VARCHAR(50),
    prompt_hash VARCHAR(64), -- Hash des verwendeten Prompts
    response_hash VARCHAR(64), -- Hash der AI-Antwort
    token_usage JSONB,
    processing_time_ms INTEGER,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    retention_until TIMESTAMP WITH TIME ZONE NOT NULL
);

-- LangChain Memory/Context (anonymisiert)
CREATE TABLE threema_data.conversation_memory (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    conversation_id UUID NOT NULL REFERENCES threema_data.conversations(id) ON DELETE CASCADE,
    memory_type VARCHAR(50) NOT NULL, -- 'short_term', 'long_term', 'summary'
    encrypted_memory TEXT, -- Verschlüsselter Kontext
    importance_score INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    retention_until TIMESTAMP WITH TIME ZONE NOT NULL
);

-- =============================================================================
-- AUDIT-LOG FÜR DSGVO-COMPLIANCE
-- =============================================================================

-- Umfassendes Audit-Log
CREATE TABLE audit_log.data_processing_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_pseudonym VARCHAR(64), -- Pseudonymisierte Benutzer-ID
    operation_type VARCHAR(50) NOT NULL, -- 'CREATE', 'READ', 'UPDATE', 'DELETE', 'PROCESS'
    table_name VARCHAR(100),
    record_id UUID,
    legal_basis VARCHAR(50) NOT NULL,
    purpose VARCHAR(200) NOT NULL,
    data_categories TEXT[], -- Array der verarbeiteten Datenkategorien
    automated_decision BOOLEAN DEFAULT false,
    retention_applied BOOLEAN DEFAULT false,
    ip_address INET,
    user_agent TEXT,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    additional_metadata JSONB
);

-- DSGVO-Anfragen-Log
CREATE TABLE audit_log.gdpr_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES threema_data.users(id),
    request_type VARCHAR(50) NOT NULL, -- 'access', 'rectification', 'erasure', 'portability'
    status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'completed', 'rejected'
    requested_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP WITH TIME ZONE,
    request_details JSONB,
    response_data JSONB
);

-- =============================================================================
-- INDIZES FÜR PERFORMANCE
-- =============================================================================

-- Benutzer-Indizes
CREATE INDEX idx_users_threema_id ON threema_data.users(threema_id);
CREATE INDEX idx_users_pseudonym ON threema_data.users(pseudonym_hash);
CREATE INDEX idx_users_retention ON threema_data.users(data_retention_until);

-- Nachrichten-Indizes
CREATE INDEX idx_messages_conversation ON threema_data.messages(conversation_id);
CREATE INDEX idx_messages_timestamp ON threema_data.messages(timestamp);
CREATE INDEX idx_messages_retention ON threema_data.messages(retention_until);

-- Audit-Log-Indizes
CREATE INDEX idx_audit_timestamp ON audit_log.data_processing_log(timestamp);
CREATE INDEX idx_audit_user ON audit_log.data_processing_log(user_pseudonym);
CREATE INDEX idx_audit_operation ON audit_log.data_processing_log(operation_type);

-- =============================================================================
-- DSGVO-FUNKTIONEN
-- =============================================================================

-- Funktion für automatische Datenlöschung
CREATE OR REPLACE FUNCTION delete_expired_data()
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER := 0;
BEGIN
    -- Benutzer und abhängige Daten löschen
    WITH deleted_users AS (
        DELETE FROM threema_data.users 
        WHERE data_retention_until < CURRENT_TIMESTAMP 
        RETURNING id
    )
    SELECT COUNT(*) INTO deleted_count FROM deleted_users;
    
    -- Abgelaufene Nachrichten löschen
    DELETE FROM threema_data.messages 
    WHERE retention_until < CURRENT_TIMESTAMP;
    
    -- Abgelaufene AI-Interaktionen löschen
    DELETE FROM threema_data.ai_interactions 
    WHERE retention_until < CURRENT_TIMESTAMP;
    
    -- Abgelaufene Memory-Daten löschen
    DELETE FROM threema_data.conversation_memory 
    WHERE retention_until < CURRENT_TIMESTAMP;
    
    -- Audit-Log bereinigen (nach 7 Jahren)
    DELETE FROM audit_log.data_processing_log 
    WHERE timestamp < CURRENT_TIMESTAMP - INTERVAL '7 years';
    
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- Trigger für automatische Timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers anwenden
CREATE TRIGGER update_users_updated_at 
    BEFORE UPDATE ON threema_data.users 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_profiles_updated_at 
    BEFORE UPDATE ON threema_data.user_profiles 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =============================================================================
-- BERECHTIGUNGEN
-- =============================================================================

-- n8n-Benutzer Berechtigungen
GRANT USAGE ON SCHEMA threema_data TO n8n_user;
GRANT USAGE ON SCHEMA audit_log TO n8n_user;

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA threema_data TO n8n_user;
GRANT INSERT ON ALL TABLES IN SCHEMA audit_log TO n8n_user;
GRANT SELECT ON audit_log.gdpr_requests TO n8n_user;

GRANT USAGE ON ALL SEQUENCES IN SCHEMA threema_data TO n8n_user;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA audit_log TO n8n_user;

-- =============================================================================
-- TESTDATEN (ENTWICKLUNG)
-- =============================================================================

-- Beispiel-Benutzer für Tests (nur in Entwicklungsumgebung)
INSERT INTO threema_data.users (
    threema_id, 
    pseudonym_hash, 
    consent_given, 
    consent_timestamp,
    data_retention_until
) VALUES (
    'TEST1234',
    encode(sha256('TEST1234'::bytea), 'hex'),
    true,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP + INTERVAL '30 days'
) ON CONFLICT (threema_id) DO NOTHING;

-- Audit-Log-Eintrag für Setup
INSERT INTO audit_log.data_processing_log (
    user_pseudonym,
    operation_type,
    table_name,
    legal_basis,
    purpose,
    data_categories
) VALUES (
    'system',
    'CREATE',
    'database_schema',
    'legitimate_interest',
    'System initialization for GDPR-compliant messaging',
    ARRAY['system_logs']
); 