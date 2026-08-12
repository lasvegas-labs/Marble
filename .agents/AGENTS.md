# Project Rules & Workflows

## Local Development Configuration Workflow
Setiap kali melakukan `git pull origin main` yang menimpa file `project.pbxproj` atau `*.entitlements` dengan konfigurasi anggota tim lain, jalankan script helper berikut di terminal lokal untuk mengembalikan Team ID, Bundle ID, dan App Group ke konfigurasi personal milik Otniel:

```bash
bash .agents/apply_my_config.sh
```

### Parameter Konfigurasi Personal Otniel:
- **Team ID**: `3W3H2RL43R`
- **Bundle ID Prefix**: `com.otniel.Marble`
- **App Group**: `group.otniel`
- **Backup File Entitlements**: Tersimpan di folder `.agents/dev_configs/`