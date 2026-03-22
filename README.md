# 📝 Note App - Flutter & Firebase

A professional, real-time note-taking application built with **Flutter** and **Firebase Cloud Firestore**. This project demonstrates a complete CI/CD workflow using **GitHub Actions** and **Google's Release Please**.

![GitHub release (latest by date)](https://img.shields.io/github/v/release/iamlasantha/note-app?color=purple&style=flat-square)
![Build Status](https://img.shields.io/github/actions/workflow/status/iamlasantha/note-app/release-please.yml?style=flat-square)
![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=flat-square&logo=Flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-%23039BE5.svg?style=flat-square&logo=Firebase&logoColor=white)

---

## 🚀 Features

- **Real-time Sync:** Powered by Cloud Firestore for instant updates across devices.
- **Search Functionality:** Quickly filter through your notes with the built-in search bar.
- **Pin Important Notes:** Keep your most important notes at the top of the list.
- **Full CRUD Support:** Create, Read, Update, and Delete notes seamlessly.
- **Safety First:** Delete confirmation dialogs to prevent accidental data loss.
- **Auto APK Builds:** Every official release automatically builds and attaches a production APK.

---

## 🛠️ Tech Stack

- **Frontend:** Flutter (Dart)
- **Backend:** Firebase Cloud Firestore
- **Automation:** GitHub Actions
- **Versioning:** Google Release Please (Conventional Commits)

---

## 📦 Automated Release Workflow

This project uses **Conventional Commits** to automate the release process. 

### How it works:
1. **Develop:** Work on the `dev` branch.
2. **Commit:** Use prefixes like `feat:` for new features or `fix:` for bug fixes.
3. **Merge:** Merge `dev` into `main`.
4. **Automate:** GitHub Actions triggers **Release Please**, which:
   - Updates the version (SemVer).
   - Generates a `CHANGELOG.md`.
   - Creates a GitHub Release.
   - Builds and uploads the **Release APK**.

---

## 🏁 Getting Started

### Prerequisites
- Flutter SDK installed.
- A Firebase project set up and linked via `flutterfire configure`.

### Installation
1. Clone the repository:
   ```bash
   git clone [https://github.com/iamlasantha/note-app.git](https://github.com/iamlasantha/note-app.git)
