import logging
import os
import firebase_admin
from firebase_admin import credentials, messaging

logger = logging.getLogger(__name__)

class NotificationService:
    def __init__(self):
        self._initialized = False
        self._initialize_firebase()

    def _initialize_firebase(self):
        # Prevent initializing multiple times
        if not firebase_admin._apps:
            try:
                # Path to the service account key (google-services.json equivalent for Admin SDK is a service-account.json)
                # Ensure the path is provided via env var or standard location.
                cred_path = os.getenv("FIREBASE_CREDENTIALS_PATH")
                if cred_path and os.path.exists(cred_path):
                    cred = credentials.Certificate(cred_path)
                    firebase_admin.initialize_app(cred)
                    self._initialized = True
                    logger.info("Firebase Admin SDK initialized successfully.")
                else:
                    logger.warning("Firebase credentials not found. Notifications will be mocked. Set FIREBASE_CREDENTIALS_PATH.")
            except Exception as e:
                logger.error(f"Failed to initialize Firebase Admin SDK: {e}")
        else:
            self._initialized = True

    def send_urgency_notification(self, fcm_token: str, specialty: str, distance_km: float):
        """
        Sends a critical push notification to a mechanic.
        """
        title = "¡Alerta de Urgencia!"
        body = f"¡Urgencia {specialty} a {distance_km:.1f}km de tu posición!"
        
        if not self._initialized:
            logger.warning(f"MOCK FCM: Sending '{title}' -> '{body}' to token {fcm_token}")
            return True

        try:
            message = messaging.Message(
                notification=messaging.Notification(
                    title=title,
                    body=body,
                ),
                data={
                    "type": "URGENCY",
                    "specialty": specialty,
                    "distance_km": str(distance_km)
                },
                token=fcm_token,
                android=messaging.AndroidConfig(
                    priority='high',
                    notification=messaging.AndroidNotification(channel_id='urgency_channel')
                ),
                apns=messaging.APNSConfig(
                    payload=messaging.APNSPayload(
                        aps=messaging.Aps(sound='default', content_available=True)
                    )
                )
            )
            response = messaging.send(message)
            logger.info(f"Successfully sent FCM message: {response}")
            return True
        except Exception as e:
            logger.error(f"Error sending FCM message: {e}")
            return False

    def send_client_acceptance_notification(self, fcm_token: str, mechanic_name: str, eta_minutes: int):
        """
        Notifies the driver that a mechanic has accepted the request.
        """
        title = "¡Ayuda en camino!"
        body = f"El tallerista {mechanic_name} llegará a tu posición en aprox. {eta_minutes} minutos."
        
        if not self._initialized:
            logger.warning(f"MOCK FCM: Sending '{title}' -> '{body}' to token {fcm_token}")
            return True

        try:
            message = messaging.Message(
                notification=messaging.Notification(
                    title=title,
                    body=body,
                ),
                data={
                    "type": "MECHANIC_ACCEPTED",
                    "mechanic_name": mechanic_name,
                    "eta_minutes": str(eta_minutes)
                },
                token=fcm_token,
                android=messaging.AndroidConfig(priority='high'),
                apns=messaging.APNSConfig(
                    payload=messaging.APNSPayload(aps=messaging.Aps(sound='default', content_available=True))
                )
            )
            response = messaging.send(message)
            logger.info(f"Successfully sent Client FCM message: {response}")
            return True
        except Exception as e:
            logger.error(f"Error sending Client FCM message: {e}")
            return False

notification_service = NotificationService()
