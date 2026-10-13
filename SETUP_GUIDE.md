# SmartHealthWear setup status

The current public checkout cannot be built: root settings reference `app` and `wear`, but both module directories and the Gradle wrapper are missing.

Earlier instructions referred to a separate `HealthMonitor.zip` and source files not present here. Their claims of completed features, out-of-the-box simulation, and medical/security standards compliance were not verifiable from this checkout and have been replaced with this status.

Before providing executable setup instructions:

1. Recover the complete Android and Wear OS source from the team-approved project.
2. Confirm collaborator attribution and rights for every source, SDK, and asset.
3. Include a compatible Gradle wrapper and module build files; document SDK/JDK versions from actual build evidence.
4. Keep Firebase configuration, service-account credentials, AI keys, signing keys, device logs, and real health records outside Git.
5. Run builds and tests, then distinguish synthetic sensor simulation from actual smartwatch measurements.

Firestore rules in the repository express owner-based access checks. A rules file alone does not establish ISO 27001, ISO 13485, IEC 62304, ISO/IEEE 11073 compliance, clinical validation, or deployed protection. Those claims require evidence beyond ordinary authentication and software structure.
