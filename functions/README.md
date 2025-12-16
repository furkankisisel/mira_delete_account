# Firebase Cloud Function: deleteAccount

This function deletes a Firebase Authentication user by email and removes their Firestore data.

## Endpoint
After deployment, you'll get a URL like:

```
https://<region>-<project-id>.cloudfunctions.net/deleteAccount
```

## Local development

- Install dependencies:

```
cd functions
npm install
```

- (Optional) Emulate functions:

```
firebase emulators:start --only functions
```

## Deploy

```
firebase deploy --only functions
```

## Security notes
- This sample accepts an email and performs deletion with Admin privileges.
- For production, validate an ID token or require authentication.
- Consider double-confirmation flows or rate-limiting.
