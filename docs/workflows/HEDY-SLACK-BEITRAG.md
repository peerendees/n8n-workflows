# Hedy Webhook Issue: Webhook Not Triggering

## Problem

I'm trying to integrate Hedy webhooks with n8n, but the webhooks are not being triggered when I perform a transcription.

**What happens:**
- ✅ YouTube video is successfully transcribed in Hedy
- ✅ Session is created in Hedy
- ❌ No webhook is sent to n8n
- ❌ No execution in n8n

## My Configuration

### Hedy Webhook Settings:
- **URL:** `https://n8n.srv1098810.hstgr.cloud/webhook/Hedy-Events`
- **Authentication:** Header Auth
- **Header Name:** `Authorization`
- **Header Value:** `Bearer [TOKEN]` (Token is correctly configured)
- **Event Types Enabled:**
  - ✅ `session.created`
  - ✅ `session.ended`
  - ✅ `highlight.created`
  - ✅ `todo.exported`

### n8n Configuration:
- **Workflow:** Active
- **Webhook Path:** `/Hedy-Events`
- **Authentication:** Header Auth (matches Hedy configuration)
- **Webhook URL:** Works when manually tested with curl/httpie

## What I've Already Checked

1. ✅ Workflow is active in n8n
2. ✅ Webhook URL is correct (manual test works)
3. ✅ Authentication is correctly configured (manual test works)
4. ✅ Event types are enabled in Hedy
5. ✅ Webhook is configured in Hedy

## Questions

1. **Where can I check in Hedy if a webhook was sent?**
   - Are there webhook logs or activity logs?
   - Where can I see if Hedy attempted to send the webhook?

2. **Which event types are triggered during a YouTube transcription?**
   - Is `session.created` sent immediately?
   - Is `session.ended` only sent after transcription completion?
   - Is there a delay?

3. **Are there known issues with webhooks in certain configurations?**
   - Does the webhook URL need a specific format?
   - Are there authentication limitations?

4. **How can I debug whether Hedy is sending the webhook at all?**
   - Are there debug modes or logs?
   - How can I see what Hedy sends to the webhook?

## Expected Behavior

When I transcribe a YouTube video, I expect:
1. `session.created` event when transcription starts
2. `session.ended` event after transcription completion (with transcript data)

## Additional Info

- **Hedy Version:** [Please fill in]
- **n8n Version:** [Please fill in]
- **Webhook works with manual test:** Yes (with curl/httpie)

Thank you for your help! 🙏

---

## Shorter Slack Version:

```
Hi everyone! 👋

I'm having an issue with Hedy webhooks and n8n:

**Problem:** 
YouTube videos are successfully transcribed, but webhooks are not being sent to n8n.

**What works:**
✅ Transcription in Hedy
✅ Manual webhook test (curl/httpie) works
✅ n8n workflow is active
✅ Webhook is configured in Hedy with correct URL and auth

**What doesn't work:**
❌ No webhook is triggered during transcription
❌ No execution in n8n

**Configuration:**
- URL: `https://n8n.srv1098810.hstgr.cloud/webhook/Hedy-Events`
- Auth: Header Auth with Bearer token
- Events enabled: session.created, session.ended, highlight.created, todo.exported

**Questions:**
1. Where can I check in Hedy if a webhook was sent? (Logs?)
2. Which events are triggered during YouTube transcription?
3. Are there known issues or debugging options?

Thanks for your help! 🙏
```
