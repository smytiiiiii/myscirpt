# Serveur FiveM basique

Serveur freeroam minimal, prêt à lancer : ressources par défaut de Cfx.re + une ressource perso (`basic_core`) avec quelques commandes utiles.

## Contenu

```
fivem-server/
├── server.cfg              # configuration du serveur
├── secrets.cfg.example     # modèle pour la clé de licence (à copier en secrets.cfg)
├── install.sh / install.ps1  # téléchargent FXServer (Linux / Windows)
├── start.sh / start.bat      # lancent le serveur
└── resources/
    ├── [managers]/         # mapmanager, spawnmanager
    ├── [gamemodes]/        # basic-gamemode + maps (skater, hipster)
    ├── [system]/           # baseevents
    ├── [gameplay]/         # playernames, player-data
    └── [local]/basic_core/ # ta ressource perso
```

`chat`, `sessionmanager`, `hardcap` et `rconlog` sont fournis directement avec FXServer.

## Installation

### 1. Clé de licence

Crée une clé sur <https://portal.cfx.re> (Server Registration Keys), puis :

```
cp secrets.cfg.example secrets.cfg
```

et colle ta clé dans `secrets.cfg`. Ce fichier est ignoré par git : ne le publie jamais.

### 2. Télécharger FXServer

- **Windows** : clic droit sur `install.ps1` → *Exécuter avec PowerShell*.
  (Si l'extraction échoue, installe [7-Zip](https://www.7-zip.org) et relance.)
  Manuel : télécharge `server.7z` depuis <https://runtime.fivem.net/artifacts/fivem/build_server_windows/master/> et extrais-le dans `artifacts/`.
- **Linux** : `./install.sh`
  Manuel : télécharge `fx.tar.xz` depuis <https://runtime.fivem.net/artifacts/fivem/build_proot_linux/master/> et extrais-le dans `artifacts/`.

### 3. Lancer

- **Windows** : double-clic sur `start.bat`
- **Linux** : `./start.sh`

Puis dans FiveM : `F8` → `connect localhost:30120`.

Pour que d'autres joueurs se connectent, ouvre le port **30120 en TCP et UDP** sur ta box / ton pare-feu.

## Devenir admin

1. Connecte-toi au serveur : la console affiche tes identifiants (`license:...`, `fivem:...`).
2. Dans `server.cfg`, décommente et adapte une ligne :
   ```
   add_principal identifier.license:TON_IDENTIFIANT group.admin
   ```
3. Redémarre le serveur.

## Commandes (`basic_core`)

| Commande | Description | Accès |
|---|---|---|
| `/car [modèle]` | Fait apparaître un véhicule (défaut : `adder`) | tous |
| `/dv` | Supprime le véhicule actuel / le dernier proche | tous |
| `/fix` | Répare le véhicule | tous |
| `/heal` | Vie et armure au max | tous |
| `/tpm` | Téléportation au point de passage de la carte | tous |
| `/coords` | Affiche ta position (`vector4`) | tous |
| `/aide` | Liste des commandes | tous |
| `/announce <message>` | Annonce à tout le serveur | admin |

Les réglages (véhicule par défaut, plaque, message de bienvenue) sont dans `resources/[local]/basic_core/config.lua`.

## Ajouter une ressource

1. Mets le dossier de la ressource dans `resources/[local]/`.
2. Ajoute `ensure nom_de_la_ressource` dans `server.cfg`.
3. Redémarre, ou dans la console du serveur : `refresh` puis `ensure nom_de_la_ressource`.

## txAdmin (optionnel)

Pour utiliser le panel web txAdmin à la place : lance `FXServer.exe` (ou `run.sh`) **sans** `+exec server.cfg`, ouvre l'URL affichée dans la console et choisis ce dossier comme *Server Data Folder*.
