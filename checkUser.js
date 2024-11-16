    const admin = require('firebase-admin');

    // Replace the path with the path to your Firebase service account key
    const serviceAccount = require('./oportal-fd9c0-firebase-adminsdk-t0qfo-4cdec8a404.json');

    admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
    });
    
    const db = admin.firestore();
    
    async function listUsers() {
        const snapshot = await db.collection('users').get();
        if (snapshot.empty) {
        console.log('No users found.');
        return;
        }
    
        snapshot.forEach(doc => {
        console.log(doc.id, '=>', doc.data());
        });
    }
    
    async function listOrders() {
        const snapshot = await db.collection('orders').get();
        const items = await db.collection('items').get();
        if (snapshot.empty) {
        console.log('No orders found.');
        return;
        }
    
        snapshot.forEach(doc => {
            console.log(doc.id, '=>', doc.data());
        });

        if (items.empty) {
            console.log('No items found.');
            return;
        }
        items.forEach(doc => {
            console.log(doc.id, '=>', doc.data());
            console.log('Item ID:', doc.data().itemId);
            console.log('Item Name:', doc.data().itemName);
        });

        // Search in items for the item the itemId in the order
        snapshot.forEach(doc => {
            const order = doc.data();
            const itemId = order.itemId;
            console.log('Order ID:', doc.id);
            const item = items.docs.find(item => item.data().itemId === itemId).data();
            console.log('Order item:', item.itemName);
        });
    }

    async function checkUser(username) {
        const userDoc = await db.collection('users').doc(username).get();
        if (userDoc.exists) {
        console.log('User data:', userDoc.data());
        } else {
        console.log('User does not exist');
        }
    }
    
    // List all users to verify their existence and structure
    listUsers();

    // List all orders to verify their existence and structure
    listOrders();
    
    // Replace 'username0' with the username you want to check
    checkUser('username0');