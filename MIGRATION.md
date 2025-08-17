**Prompt para IA Especialista em Flutter com MVVM:**

**Objective:**
Migrate the existing codebase to a feature-based MVVM architecture while maintaining the original file structure. Perform the migration **one module/feature at a time**, ensuring that each feature is fully migrated, tested, and refactored before moving on to the next one. Only adjust the necessary imports, without altering the internal structure of the files. After the migration, remove the outdated files and commit the changes accordingly. **Preserve the original names of the features and their components** (e.g., do not rename `Model` to `Entity`). **Do not create barrel/index files** that export other files.

**Instructions:**

1. **Migration to Feature-Based MVVM Architecture:**

   * **Organize by Features:** Create separate feature directories for each module (e.g., `auth`, `profile`, `dashboard`) and structure them with the MVVM architecture in mind. Each feature should have its own `Model`, `ViewModel`, and `View`.
   * **Model:** Ensure that each feature has a data model that represents the business logic and data structure for that specific feature.
   * **ViewModel:** Implement a `ViewModel` for each feature that exposes data and business logic to the `View` and interacts with the `Model`.
   * **View:** Structure the UI of each feature to communicate with the `ViewModel`, ensuring a clean separation of concerns. Use `StreamBuilder` or `FutureBuilder` as necessary for reactive UI updates.

2. **Migrate One Module at a Time:**

   * **Migrate a Single Module:** Perform the migration **one module at a time**. Do not attempt to migrate multiple features or modules in parallel. Complete the migration of one feature, test it, and ensure it works properly before moving on to the next.
   * **No Internal Structure Change:** **Do not alter the internal structure** of the migrated files. The goal is to migrate the feature to the new feature-based MVVM structure without changing how the internal logic of the files works. Focus only on adjusting imports and restructuring them according to the feature-based organization.

3. **Preserve Original Names:**

   * **Keep Feature Names Consistent:** **Do not change the original names** of the components of each feature. For example, do not rename `Model` to `Entity`, or change any other component names. Keep the original naming conventions for each feature to ensure consistency across the codebase.

4. **Adjust Imports:**

   * **Update Imports Only:** The only changes to be made to the migrated files should be to **adjust the imports** so they point to the new feature-based structure. Ensure that all imports are correctly updated to reflect the new directory structure without duplicating or moving internal code logic.

5. **Remove Old Files:**

   * **Delete Outdated Files:** Once a feature has been migrated and validated, **remove the old implementation** of that feature that no longer fits the new feature-based structure.

6. **Commits:**

   * **Commit Process:** After each migration, create commits in the following way:

     * For each commit, include **two files**: the old file that was deleted and the new file that replaced it in the feature-based MVVM structure.
     * Ensure the commit message clearly indicates the change (e.g., "Migrated `auth.dart` to feature-based MVVM structure, deleted old `auth.dart`").
   * **Commit Frequency:** Commit after each successful migration of one module/feature, ensuring clarity and tracking of changes.

7. **Avoid Duplications:**

   * **Minimize Redundancies:** Avoid duplicating files, classes, or components during migration. Reuse existing components as much as possible, making sure that each file is organized and structured according to its corresponding feature.

8. **Avoid Barrel/Index Files:**

   * **Do Not Create Barrel Files:** **Do not create barrel files** (e.g., `index.dart` or files that export all files from a module or feature). Each file should be imported explicitly, ensuring that no unnecessary files are created that just aggregate exports from other files.

9. **Before Moving to the Next Feature:**

   * **Full Validation:** Ensure that the feature has passed all tests, works seamlessly with the rest of the app, and is aligned with Flutter’s best practices for MVVM.
   * **Correct Dependencies:** Check for any dependency or state management issues between features. Address any inconsistencies before proceeding to the next feature.

10. **Repeat for Each Feature:**
    After completing one feature, proceed to the next. Ensure that the migration process is incremental, with each feature being tested and validated before moving forward.

**Expected Outcome:**
A clean, maintainable, and modular feature-based MVVM architecture for the entire app, with all features migrated and functioning properly within their respective modules. Each feature will be independent, reusable, and easily maintainable, while maintaining the original file structure, avoiding duplications, and following proper version control practices with commits for each migration. Additionally, the **original names** of the features and components will be preserved, ensuring consistency throughout the migration process, and **no barrel files** will be created.