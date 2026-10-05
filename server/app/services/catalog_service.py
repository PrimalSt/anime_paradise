import json
from pathlib import Path
from typing import Dict, List, Any
from app.core.config import settings

class CatalogService:
    def __init__(self):
        self.characters: Dict[str, dict] = {}
        self.cases: Dict[str, dict] = {}
        self.items: Dict[str, dict] = {}
        self.furniture: Dict[str, dict] = {}
        self.dating_scripts: dict = {}
        self.reload()

    def reload(self):
        data_dir = settings.DATA_DIR
        
        with open(data_dir / "characters.json", "r", encoding="utf-8") as f:
            chars_list = json.load(f)
            self.characters = {c["id"]: c for c in chars_list}

        with open(data_dir / "cases.json", "r", encoding="utf-8") as f:
            cases_list = json.load(f)
            self.cases = {c["id"]: c for c in cases_list}

        with open(data_dir / "items.json", "r", encoding="utf-8") as f:
            items_list = json.load(f)
            self.items = {i["id"]: i for i in items_list}

        with open(data_dir / "furniture.json", "r", encoding="utf-8") as f:
            furn_list = json.load(f)
            self.furniture = {item["id"]: item for item in furn_list}

        with open(data_dir / "dating_scripts.json", "r", encoding="utf-8") as f:
            self.dating_scripts = json.load(f)

    def get_character(self, char_id: str) -> dict:
        return self.characters.get(char_id)

    def get_case(self, case_id: str) -> dict:
        return self.cases.get(case_id)

    def get_item(self, item_id: str) -> dict:
        return self.items.get(item_id)

    def get_furniture(self, furn_id: str) -> dict:
        return self.furniture.get(furn_id)

catalog = CatalogService()
