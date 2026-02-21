importScripts("https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyD5f7ydexAf0aUACoBCS9FZQ4xHx0gFEq4",
  authDomain: "projectappflutter-adf21.firebaseapp.com",
  projectId: "projectappflutter-adf21",
  storageBucket: "projectappflutter-adf21.appspot.com",
  messagingSenderId: "429711477561",
  appId: "1:429711477561:web:3da5d8924e155da6caf6e8"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage(function(payload) {
  console.log("Background message received:", payload);

  self.registration.showNotification(payload.notification.title, {
    body: payload.notification.body,
    icon: "/icons/Icon-192.png"
  });
});