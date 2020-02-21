import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
from datetime import datetime, timedelta, timezone

JST = timezone(timedelta(hours=+9), 'JST')  # 日本時間設定

cred = credentials.Certificate("priconnedb-public-firebase-adminsdk-irxy5-587932f0e0.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

class Unit(object):
    def __init__(self, name, position, starRank, uniqueEquipment, star3IconURL, star6IconURL):
        self.name = name
        self.position = position
        self.starRank = starRank
        self.uniqueEquipment = uniqueEquipment
        self.star3IconURL = star3IconURL
        self.star6IconURL = star6IconURL

    @staticmethod
    def from_dict(source):
        unit = Unit(source['name'], source['position'], source['starRank'], source['uniqueEquipment'], source['star3IconURL'], source['star6IconURL'])
        return unit

    def to_dict(self):
        dest = {
            'name': self.name,
            'position': self.position,
            'starRank': self.starRank,
            'uniqueEquipment': self.uniqueEquipment,
            'iconURL': self.star3IconURL,
            'star3IconURL': self.star3IconURL,
            'star6IconURL': self.star6IconURL,
            'lastUpdated': datetime.now(JST)
        }
        return dest

def clear_units():
    units_ref = db.collection('units')
    docs = units_ref.stream()

    for doc in docs:
        units_ref.document(doc.id).delete()

def add_unit(name, position, starRank, uniqueEquipment, star3IconURL, star6IconURL):
    units_ref = db.collection('units')
    docs = units_ref.stream()

    doc_ref = units_ref.document()
    unit = Unit(name, position, starRank, uniqueEquipment, star3IconURL, star6IconURL)
    doc_ref.set(unit.to_dict())
    print(unit.to_dict())

def units():
    units_ref = db.collection('units')
    docs = units_ref.stream()

    units = list(map(lambda doc: Unit.from_dict(doc.to_dict()), docs))
    log = 'count: ' + str(len(units))
    print(log)

    return units

# Allクリア
clear_units()
# 追加ユニット
add_unit('リマ', 105, 6, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F105-01.webp?alt=media&token=458661b7-db50-4a42-bbef-e825aada7105', 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F105-01-06.webp?alt=media&token=abbbc745-1f29-41eb-9ae1-b3fc2c598df7')
add_unit('ミヤコ', 125, 5, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F125-01.webp?alt=media&token=342f9034-f3ef-4316-86f3-d2f86ee1d266', '')
add_unit('クウカ', 130, 5, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F130-01.webp?alt=media&token=cdd4dd12-e7cc-48b1-9d0d-014826523093', '')
add_unit('ジュン', 135, 5, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F135-01.webp?alt=media&token=75e1eb10-feaf-4dc5-bbbf-4f1d645cdb58', '')
add_unit('クウカ (オーエド）', 140, 5, False, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F140-01.webp?alt=media&token=254a7c51-3bbb-49cd-aa6d-eef3343fa8f6', '')
add_unit('カオリ', 145, 5, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F145-01.webp?alt=media&token=619beff7-b3e3-40cb-9593-d3fac6e217bf', '')
add_unit('レイ (ニューイヤー)', 153, 5, False, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F153-01.webp?alt=media&token=3c6a1233-9216-487e-8144-60d93486ae1a', '')
add_unit('ペコリーヌ', 155, 6, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F155-01.webp?alt=media&token=3b31ed2b-1823-42a0-a8ba-ae87a7cc8724', 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F155-01-06.webp?alt=media&token=457e4179-08a9-40d9-a14c-93f1f072d84e')
add_unit('ルカ', 158, 5, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F158-01.webp?alt=media&token=465870da-15f5-4e0c-8927-d4a33eb02b01', '')
add_unit('ノゾミ', 160, 5, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F160-01.webp?alt=media&token=931f09c2-6108-4c07-ba53-c0661d26d993', '')
add_unit('ムイミ', 162, 5, False, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F162-01.webp?alt=media&token=86158072-4cb5-400b-8b53-1e054fdbbf14', '')
add_unit('マコト', 165, 5, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F165-01.webp?alt=media&token=44fc596a-6745-4f4f-9718-b1cf2fc0ec26', '')
add_unit('ヒヨリ (ニューイヤー)', 170, 5, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F170-01.webp?alt=media&token=c10a696a-04f2-4d2e-a6fa-fa9f72d76288', '')
add_unit('アキノ', 180, 5, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F180-01.webp?alt=media&token=0dfe4094-e361-488b-b529-38198a7b0ded', '')
add_unit('マツリ', 185, 5, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F185-01.webp?alt=media&token=66d7d16f-1f8b-4c26-a330-1e46731b14ae', '')
add_unit('エリコ (バレンタイン)', 187, 5, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F187-01.webp?alt=media&token=30dedeae-3189-44c1-b6c0-55c18ad6fdbe', '')
add_unit('アヤネ (クリスマス)', 190, 5, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F190-01.webp?alt=media&token=9a0a68a8-3a5e-41bf-a4a9-9a41943ea33c', '')
add_unit('ツムギ', 195, 5, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F195-01.webp?alt=media&token=cdf3a8c5-578d-4a4c-b6dc-b19beda3ea3a', '')
add_unit('ヒヨリ', 200, 5, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F200-01.webp?alt=media&token=f1e2f7e4-1c79-454c-b704-e15af5dc1fab', '')
add_unit('ミソギ', 205, 5, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F205-01.webp?alt=media&token=be313109-7b41-4f87-86fc-09638a0d54fe', '')
add_unit('アヤネ', 210, 5, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F210-01.webp?alt=media&token=bb1fa886-ca10-47f5-a1e5-9a8257d2f1f8', '')
add_unit('タマキ', 215, 5, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F215-01.webp?alt=media&token=0072163f-2c82-44e8-8bab-8e61bf29312a', '')
add_unit('トモ', 220, 5, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F220-01.webp?alt=media&token=c7fbdb01-216e-4094-b75b-621ef6345bc1', '')
add_unit('タマキ (サマー)', 225, 5, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F225-01.webp?alt=media&token=40fa2e07-9658-415a-8af6-553c859064b2', '')
add_unit('エリコ', 230, 5, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F230-01.webp?alt=media&token=3b13a7dd-0ddd-4b29-9a55-bb014c7eb144', '')
add_unit('ペコリーヌ (サマー)', 235, 5, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F235-01.webp?alt=media&token=517d4447-fa4d-412b-9d9c-079a289bf0d2', '')
add_unit('クルミ', 240, 5, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F240-01.webp?alt=media&token=6a83debf-3483-4429-a5e9-553bce2ee627', '')
add_unit('ジータ', 245, 5, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F245-01.webp?alt=media&token=1546c5b5-a454-4c15-947d-b40124c588f1', '')
add_unit('レイ', 250, 5, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F250-01.webp?alt=media&token=2a709dcb-fd43-4091-bf24-4b6b48b6bdd5', '')
add_unit('シズル', 285, 5, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F285-01.webp?alt=media&token=e178ca61-1868-4ed7-846e-b881e6c331c5', '')
add_unit('クリスティーナ', 290, 5, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F290-01.webp?alt=media&token=f2267837-5a09-48ef-a079-e33bb024bdc5', '')
add_unit('クルミ (クリスマス)', 295, 5, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F295-01.webp?alt=media&token=f5448725-02b0-4985-8215-4d9b0976cc2e', '')
add_unit('ミミ', 360, 5, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F360-01.webp?alt=media&token=d7348f4b-d414-49fc-bd52-9252cb6f4f1d', '')
add_unit('シノブ', 365, 5, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F365-01.webp?alt=media&token=f33ef8ec-6f85-4d97-b7c1-a08299cd54f8', '')
add_unit('シズル (バレンタイン)', 385, 5, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F385-01.webp?alt=media&token=8b11ea70-d3ab-4e5d-b67d-f08db7a15df0', '')
add_unit('マヒル', 395, 5, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F395-01.webp?alt=media&token=a5f344d3-3dd5-4659-bc2f-477cd2c0d84e', '')
add_unit('ユカリ', 405, 6, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F405-01.webp?alt=media&token=55a62bfa-7414-4c21-b436-f7128bd62dac', 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F405-01-06.webp?alt=media&token=32efe7e9-e5e5-4428-a828-aaf681f360d2')
add_unit('モニカ', 410, 5, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F410-01.webp?alt=media&token=be99502a-60a9-42b9-9fb8-9edbe00226cc', '')
add_unit('ニノン', 415, 5, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F415-01.webp?alt=media&token=26c9bca1-3bd7-439d-84eb-08b172c5e6b4', '')
add_unit('ミフユ', 420, 5, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F420-01.webp?alt=media&token=7ed3dece-89e9-49c4-ad11-238aed8b3727', '')
add_unit('イリヤ', 425, 5, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F425-01.webp?alt=media&token=a78c2e48-ea9d-4691-a326-d44ff153a7ef', '')
add_unit('サレン', 430, 5, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F430-01.webp?alt=media&token=9489ae5e-5265-40da-bc7c-7ab1dfc44168', '')
add_unit('シノブ (ハロウィン)', 440, 5, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F440-01.webp?alt=media&token=d1729e58-b051-4133-803b-b0342e42a11c', '')
add_unit('アンナ', 440, 5, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F440-02.webp?alt=media&token=0366b856-a4d9-4c51-b333-a2517e119fb8', '')
add_unit('ミフユ (サマー)', 495, 5, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F495-01.webp?alt=media&token=9723dad7-f5ef-423c-bdad-410c56ab2d2a', '')
add_unit('コッコロ', 500, 6, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F500-01.webp?alt=media&token=5886075d-6a41-4022-b81f-4956d0a1e59c', 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F500-01-06.webp?alt=media&token=820b5c06-d23b-41f9-94f5-da28a35ede9f')
add_unit('アユミ', 510, 5, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F510-01.webp?alt=media&token=e1ed4371-0274-43a9-91b5-5c500b868533', '')
add_unit('グレア', 525, 5, False, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F525-01.webp?alt=media&token=e1945d9b-2322-438c-b331-a2f114b2de4e', '')
add_unit('コッコロ (サマー)', 535, 5, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F535-01.webp?alt=media&token=cff0bf40-ad2e-4dde-9667-acfff7c75513', '')
add_unit('リン', 550, 5, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F550-01.webp?alt=media&token=6e0fbbb1-dfd9-444c-b9d9-74e16192b64c', '')
add_unit('ミツキ', 565, 5, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F565-01.webp?alt=media&token=37fcf4ec-2868-4fce-bb0e-f67b72f0ef1e', '')
add_unit('アカリ', 570, 5, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F570-01.webp?alt=media&token=ed6f102e-0ed3-4f75-a1b6-4fbb52e24b32', '')
add_unit('ヨリ', 575, 5, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F575-01.webp?alt=media&token=f1928ff1-7fe2-424e-aba5-880023a3bc2d', '')
add_unit('ミヤコ (ハロウィン)', 590, 5, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F590-01.webp?alt=media&token=977e3f1e-7ee8-45eb-b327-17311f710813', '')
add_unit('アリサ', 625, 5, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F625-01.webp?alt=media&token=1bf5fa9e-83de-4f19-9015-fcb16ac2a585', '')
add_unit('アン', 630, 5, False, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F630-01.webp?alt=media&token=0eac406c-d2a2-4f85-9e92-3acfc299a445', '')
add_unit('ルゥ', 640, 5, False, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F640-01.webp?alt=media&token=3b66fed3-4098-41fe-a70f-427ebba2f71e', '')
add_unit('リノ', 700, 6, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F700-01.webp?alt=media&token=46baf4e0-188f-4e3a-84d6-66069197e89d', 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F700-01-06.webp?alt=media&token=9dfbde29-b1e0-4c2c-8de2-2fb387e2bef7')
add_unit('スズナ', 705, 5, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F705-01.webp?alt=media&token=2e73c9d3-611a-45ce-9990-8776b025d1df', '')
add_unit('シオリ', 710, 5, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F710-01.webp?alt=media&token=a22ac923-7fe5-4d2f-9f03-d27770295559', '')
add_unit('イオ', 715, 6, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F715-01.webp?alt=media&token=35bb6067-faba-4168-b05b-a70a569f557f', 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F715-01-06.webp?alt=media&token=565ca5bd-3e23-42f0-88d4-4848031b475f')
add_unit('スズメ', 720, 5, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F720-01.webp?alt=media&token=5f98189e-b992-46f9-a666-5dc86909f8af', '')
add_unit('カスミ', 730, 5, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F730-01.webp?alt=media&token=8d7f9186-469b-4be7-8f88-1231875d427e', '')
add_unit('ミサト', 735, 5, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F735-01.webp?alt=media&token=c0c8eaac-b2a3-4f96-9171-d8ee3cd6c244', '')
add_unit('ナナカ', 740, 5, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F740-01.webp?alt=media&token=01e599e3-7030-430a-be1e-7bc7c3f4ff01', '')
add_unit('ユイ (ニューイヤー)', 745, 5, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F745-01.webp?alt=media&token=c56b4f13-c0c7-4713-95fd-398547bd8b18', '')
add_unit('キャル', 750, 6, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F750-01.webp?alt=media&token=39ba7f3d-64e2-4fb3-b258-0b12ac7b7bd4', 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F750-01-06.webp?alt=media&token=fdbebb19-1629-443c-a5cb-e50bb36fa869')
add_unit('ハツネ', 755, 5, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F755-01.webp?alt=media&token=c4352179-997f-4628-a3fb-96cac42495e8', '')
add_unit('ミサキ', 760, 5, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F760-01.webp?alt=media&token=0f5141c6-b7b6-4508-b36c-e5d4154877e8', '')
add_unit('チカ (クリスマス)', 770, 5, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F770-01.webp?alt=media&token=8c44ab66-d93d-460d-b0e7-a7e7b1ebfd59', '')
add_unit('スズメ (サマー)', 775, 5, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F775-01.webp?alt=media&token=6336c253-7ef3-4a4b-b26c-456ec60326c0', '')
add_unit('キャル (サマー)', 780, 5, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F780-01.webp?alt=media&token=c47e0368-1c8e-4fe8-bcff-e8f32e87ca1f', '')
add_unit('アオイ', 785, 5, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F785-01.webp?alt=media&token=e1f74626-dbf6-4956-8c63-b6bf6859e0d6', '')
add_unit('チカ', 790, 5, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F790-01.webp?alt=media&token=48031a39-7673-4291-a5d5-60a4b0bc95b8', '')
add_unit('マホ', 795, 6, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F795-01.webp?alt=media&token=6f0dfba0-b7d0-412f-b4ce-d20fa4be9feb', 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F795-01-06.webp?alt=media&token=37738f35-25dc-4c9f-9226-61fa61ae8140')
add_unit('ユイ', 800, 5, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F800-01.webp?alt=media&token=299bbb46-028d-406a-9528-1bdf2420461f', '')
add_unit('ユキ', 805, 5, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F805-01.webp?alt=media&token=33c1bc2c-93f7-4166-8665-1bf46ef7ddc7', '')
add_unit('キョウカ', 810, 5, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F810-01.webp?alt=media&token=8823ae72-683b-41b1-b639-6472520745ad', '')
add_unit('ミサキ (ハロウィン)', 815, 5, True, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F815-01.webp?alt=media&token=2d14d1e9-c0c3-4c6d-8ea0-db841d1669d6', '')
add_unit('ニノン (オーエド)', 175, 5, False, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F175-01.webp?alt=media&token=11fb1078-90a8-4c99-b76a-06ea21dcb8fd', '')
add_unit('レム', 540, 5, False, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F540-01.webp?alt=media&token=04e31437-42df-4d68-8e58-7870ca0777cd', '')
add_unit('ラム', 545, 5, False, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F545-01.webp?alt=media&token=7edae85a-89d4-4b16-bae5-b4597a866227', '')
add_unit('エミリア', 725, 5, False, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F725-01.webp?alt=media&token=8506b624-79d4-4705-a7a4-7cc2df0251d6', '')
add_unit('スズナ（サマー）', 705, 5, False, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F705-02.webp?alt=media&token=5451fcdf-515f-45b1-bb4c-339f8fee5440', '')
add_unit('イオ（サマー）', 715, 5, False, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F715-02.webp?alt=media&token=b30cb07a-a770-458c-a5c0-8940e7373cd7', '')
add_unit('サレン（サマー）', 585, 5, False, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F585-01.webp?alt=media&token=f8673ba8-0b09-45cf-92d2-f8fa776b5d2c', '')
add_unit('マコト（サマー）', 180, 5, False, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F185-02.webp?alt=media&token=9b78a4a3-3b2a-4c4f-8946-e3be68ecff48', '')
add_unit('カオリ（サマー）', 425, 5, False, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F425-02.webp?alt=media&token=c9bb5749-d27c-466e-8388-c0b39db5a1a2', '')
add_unit('マホ（サマー）', 792, 5, False, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F792-01.webp?alt=media&token=dd145b9d-9628-47de-9d00-2d656bd20546', '')
add_unit('ネネカ', 660, 5, False, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F660-01.webp?alt=media&token=09c31b98-8a01-4e45-95c6-15c1432b0b8b', '')
add_unit('アオイ（転入生）', 680, 5, False, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F680-01.webp?alt=media&token=0fd045aa-2312-43ae-aa55-0d2d7c04280b', '')
add_unit('クロエ', 185, 5, False, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F185-02.webp?alt=media&token=9b78a4a3-3b2a-4c4f-8946-e3be68ecff48', '')
add_unit('ミソギ （ハロウィン）', 212, 5, False, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F212-01.webp?alt=media&token=901fa4e0-a0f9-4120-96dd-d6fe197b59da', '')
add_unit('キョウカ（ハロウィン）', 820, 5, False, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F820-01.webp?alt=media&token=8ee00712-aa23-4e49-a765-e32970a795ba', '')
add_unit('ミミ（ハロウィン）', 365, 5, False, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F365-02.webp?alt=media&token=265c435a-44b1-4e0a-b73f-4049c1ec5fe3', '')
add_unit('ルナ', 765, 5, False, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F765-01.webp?alt=media&token=5c9ff980-3c46-4403-86a6-79d9b23c0156', '')
add_unit('カヤ', 168, 5, False, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F168-01.webp?alt=media&token=e6cf14ea-abec-48fc-98b5-8a311564ee43', '')
add_unit('クリスティーナ（クリスマス）', 265, 5, False, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F265-01.webp?alt=media&token=5bc46d79-51b5-4f33-b770-f6228ccb2965', '')
add_unit('ノゾミ（クリスマス）', 418, 5, False, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F418-01.webp?alt=media&token=ca2f062b-80ae-4ac5-af85-f4b10802fb62', '')
add_unit('イリヤ（クリスマス）', 255, 5, False, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F255-01.webp?alt=media&token=86d1d433-3242-4d52-9b60-75d37895855f', '')
add_unit('キャル（ニューイヤー）', 690, 5, False, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F690-01.webp?alt=media&token=39de2c54-7eca-438b-8e80-ba6595d21b80', '')
add_unit('スズメ（ニューイヤー）', 722, 5, False, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F722-01.webp?alt=media&token=6b242e61-fe32-42ed-9e14-6f0db6f41e7d', '')
add_unit('コッコロ（ニューイヤー）', 159, 5, False, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F159-01.webp?alt=media&token=615ca1b5-08d6-462f-b7ef-b08485bfa9fe', '')
add_unit('シオリ（マジカル）', 712, 5, False, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F712-01.webp?alt=media&token=ada36818-e41d-4046-ac16-6b506f61a6d5', '')
add_unit('カスミ（マジカル）', 730, 5, False, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F730-02.webp?alt=media&token=5436f67a-6411-42ea-b189-ad37fd89a61d', '')
add_unit('ペコリーヌ（プリンセス）', 155, 5, False, 'https://firebasestorage.googleapis.com/v0/b/priconnedb-public.appspot.com/o/unit%2F155-02.webp?alt=media&token=cfba86e2-6aa8-4dd0-b10e-d7074eb5dd1f', '')

units()
