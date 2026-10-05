import json

with open(r'c:\Users\Михаил\Desktop\code\Gemini\Anime_paradise\server\app\data\characters.json', 'r', encoding='utf-8') as f:
    chars = json.load(f)

new_chars = [
    {
        "id": "madoka_magica",
        "name": "Мадока Канаме",
        "title": "Волшебная девочка",
        "franchise": "Madoka Magica",
        "rarity": "SSR",
        "bio": "Добрая и искренняя девочка, готовая пожертвовать собой ради спасения других.",
        "favorite_food": ["strawberry_cake", "tea_buns"],
        "base_stats": {
            "charm": 95,
            "energy": 85,
            "intellect": 80
        },
        "default_outfit": "Розовое платье",
        "outfits": [
            { "id": "default", "name": "Розовое платье", "unlocked": True }
        ],
        "dialogues": {
            "greeting": "Привет! Я Мадока. Я хочу стать сильной, чтобы защитить всех!",
            "headpat": "Хе-хе, спасибо! Твоя забота делает меня счастливее.",
            "feed": "Тортик? Какой вкусный! Обожаю сладости.",
            "level_up": "Я чувствую, что моя магия стала еще сильнее!"
        }
    },
    {
        "id": "sinon_sao",
        "name": "Синон",
        "title": "Ледяной снайпер",
        "franchise": "Sword Art Online",
        "rarity": "SR",
        "bio": "Хладнокровная и расчётливая девушка-снайпер в виртуальном мире, но робкая в реальности.",
        "favorite_food": ["beef_steak", "curry_ramen"],
        "base_stats": {
            "charm": 80,
            "energy": 88,
            "intellect": 92
        },
        "default_outfit": "Экипировка снайпера GGO",
        "outfits": [
            { "id": "default", "name": "Экипировка снайпера GGO", "unlocked": True }
        ],
        "dialogues": {
            "greeting": "Цель захвачена. Можешь на меня положиться.",
            "headpat": "Ч-что ты делаешь?! Не думай, что я так просто растаю...",
            "feed": "Спасибо за еду. В бою нужна хорошая реакция, а для этого нужна энергия.",
            "level_up": "Мой прицел стал еще острее. Никто не уйдет от моего выстрела."
        }
    },
    {
        "id": "violet_evergarden",
        "name": "Вайолет Эвергарден",
        "title": "Автозапоминающая кукла",
        "franchise": "Violet Evergarden",
        "rarity": "UR",
        "bio": "Бывший солдат, пытающаяся понять смысл слов «Я люблю тебя» через написание писем для других.",
        "favorite_food": ["matcha_tea", "tea_buns"],
        "base_stats": {
            "charm": 92,
            "energy": 90,
            "intellect": 94
        },
        "default_outfit": "Униформа почтовой компании",
        "outfits": [
            { "id": "default", "name": "Униформа почтовой компании", "unlocked": True }
        ],
        "dialogues": {
            "greeting": "Вы желаете написать письмо? Я к вашим услугам.",
            "headpat": "Это... проявление привязанности? Я постараюсь запомнить это чувство.",
            "feed": "Благодарю вас. Эта еда восполнит мои силы для работы.",
            "level_up": "Я шаг за шагом приближаюсь к пониманию человеческого сердца."
        }
    }
]

chars.extend(new_chars)

with open(r'c:\Users\Михаил\Desktop\code\Gemini\Anime_paradise\server\app\data\characters.json', 'w', encoding='utf-8') as f:
    json.dump(chars, f, ensure_ascii=False, indent=2)

print("Added characters!")
