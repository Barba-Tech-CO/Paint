**Prompt para IA Especialista em Flutter com MVVM:**

**Objective:**
Migrate the existing codebase to a feature-based MVVM architecture while maintaining the original file structure. Perform the migration **one module/feature at a time**, ensuring that each feature is fully migrated, tested, and refactored before moving on to the next one. Once the migration is complete, delete the outdated files and create commits following the specified format. Afterward, prompt the user to select the next module/feature to migrate. **Include migration of widgets (e.g., Bottom Navigation Bar) as part of the feature migration**, keeping them within the feature directories unless they are reusable.

**Instructions:**

1. **Choose a Module for Migration:**

   * **Pick One Module:** Choose one module or feature from the codebase to migrate first. Ensure the migration is complete for that module before moving on to the next.

2. **Migration to Feature-Based MVVM Architecture:**

   * **Organize by Features:** Create separate feature directories for each module (e.g., `auth`, `profile`, `dashboard`) and structure them with the MVVM architecture in mind. Each feature should have its own `Model`, `ViewModel`, `View`, and `widgets` if needed.
   * **Model:** Ensure that each feature has a data model that represents the business logic and data structure for that specific feature.
   * **ViewModel:** Implement a `ViewModel` for each feature that exposes data and business logic to the `View` and interacts with the `Model`.
   * **View:** Structure the UI of each feature to communicate with the `ViewModel`, ensuring a clean separation of concerns. Use `StreamBuilder` or `FutureBuilder` as necessary for reactive UI updates.
   * **Widgets:**

     * If the widget (e.g., **Bottom Navigation Bar**) is **specific to the feature**, move it into the `widgets` folder within that feature directory.
     * **Widgets used in more than one screen should not be placed inside the feature directory**. Instead, they should be placed in a **global `widgets/` directory** or `common/widgets/`, ensuring they can be reused across different features without duplication.

3. **Service Migration:**

   * **Do Not Migrate Services:** **Services (e.g., `AuthService`, `NetworkService`, `StorageService`) should not be migrated as part of the feature-based MVVM migration**. These services are shared across features and should remain in a global `services` folder outside of the feature directories.
   * Services will continue to exist in a separate directory like `lib/services`, and should be used within the `ViewModel` of each feature.

4. **No Internal Structure Change:**

   * **Do Not Alter Internal Logic:** Do not change the internal structure of the migrated files. The focus should be solely on adjusting imports and restructuring them according to the feature-based organization without altering the business logic.

5. **Adjust Imports:**

   * **Update Imports Only:** The only changes to be made to the migrated files should be to **adjust the imports** so they point to the new feature-based structure.

6. **Remove Old Files:**

   * **Delete Outdated Files:** After a feature has been migrated and validated, **remove the old implementation** that no longer fits the feature-based MVVM structure.

7. **Commits:**

   * **Follow Conventional Commits Format:** After each migration, create commits following the **conventional commits** format:

     * **Commit Type**: Use appropriate commit types like `feat`, `fix`, `refactor`, etc.
     * **Commit Message Format**: Each commit message should be clear and concise, following the pattern:

       ```
       <type>(<scope>): <short message>
       ```
     * **Commit Content:** For each commit, include **two files**: the old file that was deleted and the new file that replaced it in the feature-based MVVM structure.
     * Example commit message:

       ```
       feat(auth): migrate to feature-based MVVM structure, delete old auth.dart
       ```

8. **Ask for the Next Module:**

   * **Prompt the User:** After completing the migration for a feature and committing the changes, **ask the user for the next module/feature to migrate**. Provide a list of remaining features that have not been migrated yet.

     * **Example question:**
       "Which module/feature would you like to migrate next? Here are the remaining options:

       * `profile`
       * `settings`
       * `dashboard`"

9. **Repeat the Process:**

   * After completing the migration of one module, proceed to the next as directed by the user. Ensure that each module is fully migrated, tested, and validated before moving on to the next one.

**Expected Outcome:**
A clean, maintainable, and modular feature-based MVVM architecture for the entire app, with all features migrated and functioning properly within their respective modules. Each feature will be independent, reusable, and easily maintainable, while maintaining the original file structure, avoiding duplications, and following proper version control practices with commits for each migration. After each migration, the user will be prompted to choose the next feature/module to migrate.