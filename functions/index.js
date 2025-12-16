/*
  Cloud Function: deleteAccount
  - Accepts JSON { email: string }
  - Locates Firebase Auth user by email
  - Deletes user from Auth
  - Deletes all Firestore documents for that user under conventional collections
  - Handles CORS and returns structured JSON
  SECURITY: Consider validating ID tokens for real apps (not included here per requirements)
*/

const functions = require('firebase-functions');
const admin = require('firebase-admin');
const cors = require('cors')({ origin: true });

// Initialize admin once
try {
    admin.initializeApp();
} catch (e) {
    // no-op if already initialized
}

const db = admin.firestore();

// Helper to delete a collection in batches
async function deleteCollection(collectionRef, batchSize = 200) {
    let query = collectionRef.limit(batchSize);
    while (true) {
        const snapshot = await query.get();
        if (snapshot.empty) break;
        const batch = db.batch();
        snapshot.docs.forEach((doc) => batch.delete(doc.ref));
        await batch.commit();
    }
}

// Helper to delete a document and its subcollections (depth-1)
async function deleteDocumentRecursive(docRef) {
    const subcollections = await docRef.listCollections();
    for (const sub of subcollections) {
        await deleteCollection(sub);
    }
    await docRef.delete();
}

exports.deleteAccount = functions.https.onRequest((req, res) => {
    cors(req, res, async () => {
        if (req.method !== 'POST') {
            return res.status(405).json({ error: 'Method Not Allowed' });
        }

        try {
            const { email } = req.body || {};
            if (!email || typeof email !== 'string') {
                return res.status(400).json({ error: 'Missing or invalid email' });
            }

            // Lookup user
            let userRecord;
            try {
                userRecord = await admin.auth().getUserByEmail(email);
            } catch (err) {
                if (err.code === 'auth/user-not-found') {
                    return res.status(404).json({ error: 'User not found' });
                }
                throw err;
            }

            const uid = userRecord.uid;

            // Firestore cleanup (adjust to your app schema)
            // Example structure:
            // users/{uid} + subcollections; habits/{uid}_*, visions/{uid}_*, transactions owned by uid, etc.
            // Below we clean a typical structure: users doc + all subcollections
            const userDocRef = db.collection('users').doc(uid);
            await deleteDocumentRecursive(userDocRef);

            // If you store per-user docs in other top-level collections, delete them here as well.
            // Example: await deleteCollection(db.collection('habits').where('uid', '==', uid));
            // Example: await deleteCollection(db.collection('visions').where('uid', '==', uid));
            // Example: await deleteCollection(db.collection('transactions').where('uid', '==', uid));

            // Delete from Auth last
            await admin.auth().deleteUser(uid);

            return res.status(200).json({ ok: true });
        } catch (err) {
            console.error('deleteAccount error:', err);
            return res.status(500).json({ error: 'Internal error' });
        }
    });
});
