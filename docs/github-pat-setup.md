# GitHub Personal Access Token Setup Guide

## Steps to Create a PAT

1. **Go to GitHub:**
   - Visit: https://github.com/settings/tokens
   - Or: GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)

2. **Generate New Token:**
   - Click "Generate new token" → "Generate new token (classic)"
   
3. **Configure Token:**
   - **Note:** `homelab-access` (or any name you prefer)
   - **Expiration:** Choose based on preference (90 days, 1 year, or no expiration)
   - **Scopes:** Select these permissions:
     - ✅ `repo` (Full control of private repositories)
       - This automatically selects all repo sub-permissions
   
4. **Generate and Copy:**
   - Click "Generate token" at the bottom
   - **IMPORTANT:** Copy the token immediately - you won't see it again!
   - Format: `ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`

## After You Have the Token

Come back here and I'll help you configure git to use it.

## Security Notes

- Store the token securely (consider using Vaultwarden!)
- Don't commit the token to git
- If compromised, revoke it immediately at the same URL
- Can create multiple tokens for different purposes

## Alternative: Git Credential Helper

I can configure git to remember your token so you only enter it once.
