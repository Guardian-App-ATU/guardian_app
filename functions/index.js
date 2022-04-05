const functions = require("firebase-functions");
const admin = require("firebase-admin");
const {HttpsError} = require("firebase-functions/v2/https");
const {firestore} = require("firebase-admin");
admin.initializeApp()

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

let db = admin.firestore()

exports.createTimestamp = functions.firestore.document("sessions/{sessionId}")
    .onCreate((snap) => {
        return snap.ref.set({
            "createdAt": admin.firestore.FieldValue.serverTimestamp()
        }, {merge: true})
    })

exports.userOnCreate = functions.auth.user().onCreate((user, context) => {
    return db.doc(`users/${user.uid}`).set({
        displayName: user.displayName ?? user.email,
        avatar: user.photoURL,
        friends: []
    })
})

exports.userOnDelete = functions.auth.user().onDelete( (user) => {
    return db.doc(`users/${user.uid}`).delete()
})

exports.updateLocation = functions.https.onCall(async (data, context) => {
    if(!data.longitude || !data.altitude){
        throw new HttpsError("invalid-argument", "no location 'longitude' or 'altitude' arguments present")
    }

    const parsedL = parseFloat(data.longitude), parsedA = parseFloat(data.altitude);

    if(isNaN(parsedL) || isNaN(parsedA)){
        throw new HttpsError("invalid-argument", "wrong argument format")
    }

    let documents = await db.collection("sessions")
        .where("userId", "==", context.auth?.uid ?? "-1")
        .where("closed", "==", false)
        // .where("expiryDate", ">", Date.now()) //edited this already
        .get();

    let geoPoint = new admin.firestore.GeoPoint(data.altitude, data.longitude);

    let batch = db.batch();
    documents.forEach((doc) => {
        batch.update(doc.ref, {
            locations: firestore.FieldValue.arrayUnion(geoPoint)
        })
    })

    console.log(`Commiting batch update on ${documents.docs.length} batch size: ${batch._opCount}!`)
    await batch.commit()

    return {
        message: "updated locations"
    }
})

exports.createSession = functions.https.onCall(async (data, context) => {
    if(!data.expire)
    {
        throw new HttpsError("invalid-argument", "expire argument missing")
    }

    let parsed = parseInt(data.expire);
    if(isNaN(parsed) || parsed < 15 || parsed > 45)
    {
        throw new HttpsError("invalid-argument", "invalid range for expire argument")
    }

    let documentSnapshot = await db.doc(`users/${context.auth.uid}`).get();
    if (!documentSnapshot.exists) {
        throw new functions.https.HttpsError('not-found', 'user not found', 'authenticated user ' +
            'is not in the users/ collection')
    }

    await db.collection("sessions").add({
        userId: context.auth.uid,
        expiryDate: new Date(Date.now() + (data.expire ?? 15) * 60000),
        closed: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        locations: [],
        users: []
    })

    return {
        message: "Created a session!"
    }
})

exports.closeSession = functions.https.onCall(async (data, context) => {
    if(!data.session || typeof data.session != "string"){
        throw new HttpsError("invalid-argument", "You need to specify session argument (string)!")
    }

    const requestedDocument = await db.doc(`sessions/${data.session}`).get();

    if(!requestedDocument.exists){
        throw new HttpsError("not-found", "Couldn't find the requested session")
    }

    if(requestedDocument.get("userId") != context.auth.uid){
        throw new HttpsError("permission-denied", "You can not close session that you're not an owner of!")
    }

    if(requestedDocument.get("closed") == true){
        throw new HttpsError("failed-precondition", "This session is already closed")
    }

    await requestedDocument.ref.update({
        closed: true
    })

    return {
        message: "Successfully closed session!"
    }
})