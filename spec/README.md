- Spec files in the `spec/mysql/` and `spec/pg/` folders are meant to be separated from others as they manage database connections with different databases and adapters.
- Spec files that don't need a database connection can be in the `spec/common/` folder.
- Spec files implementing logic for a specific adapter might be under a specific folder, being `spec/yesql/mysql` and/or `spec/yesql/pg`.
