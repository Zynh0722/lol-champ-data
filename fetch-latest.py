import requests
import json

def get_version(cache = True):
    response = requests.get("https://ddragon.leagueoflegends.com/api/versions.json")
    content = json.loads(response.content)

    if cache:
        with open('data/versions.json', 'w') as json_file:
            json.dump(content, json_file, indent=4)

    return content[0]


def get_champion_data(cache = True):
    response = requests.get(f"http://ddragon.leagueoflegends.com/cdn/{get_version()}/data/en_US/champion.json")
    content = json.loads(response.content)

    if cache:
        with open('data/champions.json', 'w') as json_file:
            json.dump(content, json_file, indent=4)

    return content

print(get_champion_data())