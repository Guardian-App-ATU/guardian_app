const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp()

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

var db = admin.firestore()

exports.createTimestamp = functions.firestore.document("sessions/{sessionId}")
    .onCreate((snap) => {
        return snap.ref.set({
            "createdAt": admin.firestore.FieldValue.serverTimestamp()
        }, {merge: true})
    })

exports.userOnCreate = functions.auth.user().onCreate((user, context) => {
    return db.doc(`users/${user.uid}`).set({
        displayName: user.displayName,
        avatar: user.photoURL
    })
})

exports.createSession = functions.https.onCall(async (data, context) => {
    let documentSnapshot = await db.doc(`users/${context.auth.uid}`).get();

    if (!documentSnapshot.exists) {
        throw new functions.https.HttpsError('not-found', 'user not found', 'authenticated user ' +
            'is not in the users/ collection')
    }

    await db.collection("sessions").add({
        userId: context.auth.uid,
        expiryDate: new Date(Date.now() + 30 * 60000),
        closed: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp()
    })

    return {
        message: "Created a session!"
    }
})