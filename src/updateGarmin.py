#!/usr/bin/env python3
# %%
import os
import sqlite3
import pandas as pd
import subprocess
import datetime
# %%


def main():
    """
    Main function to:

    Step 1: Update GarminDB (Ensure we have the latest activity data).
    Step 2: Connect to the database and retrieve the activity table.
    Step 3: Export all activity records to a single CSV file in the current folder.
    """

    # Step 1: Update the GarminDB database
    print("\n[STEP 1] Updating GarminDB to fetch the latest activity data...")
    update_garmin_db()

    # Step 2: Connect to database and retrieve the activity table
    db_file = "/Users/Grace/HealthData/DBs/garmin_activities.db"
    print(f"\n[STEP 2] Connecting to the database: {db_file}")
    conn = connect_to_database(db_file)

    # Step 3: Export all activity data to a single CSV file in the current folder
    print("\n[STEP 3] Exporting all activities to a single CSV file...")
    export_activity_to_csv(conn)

    # Close the database connection
    conn.close()
    print("\n✅ All steps completed successfully!")
# %%


def update_garmin_db():
    """Runs the GarminDB update command to ensure the database is up-to-date."""
    update_command = "garmindb_cli.py --all --download --import --analyze --latest"
    process = subprocess.run(update_command, shell=True,
                             capture_output=True, text=True)

    if process.returncode != 0:
        print("❌ Error updating GarminDB:")
        print(process.stderr)
        exit(1)

    print("✅ GarminDB update completed successfully!")
# %%


def connect_to_database(db_path):
    """Establishes a connection to the Garmin database."""
    if not os.path.exists(db_path):
        print(f"❌ Database file '{db_path}' not found!")
        exit(1)
    return sqlite3.connect(db_path)
# %%


def export_activity_to_csv(conn):
    """Exports all activity data from the database to a single CSV file in the current folder."""

    # Check if the activity table exists
    cursor = conn.cursor()
    tables = cursor.execute(
        "SELECT name FROM sqlite_master WHERE type='table';").fetchall()
    table_names = [t[0] for t in tables]

    if "activities" not in table_names:
        print("❌ Error: The 'activities' table does not exist in the database.")
        exit(1)

    # Read the activity table
    df = pd.read_sql_query("SELECT * FROM activities", conn)

    # Generate timestamp for file versioning
    timestamp = datetime.datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    csv_filename = f"Garmin_activities.csv"  # Save directly in the current folder

    # Export to CSV
    df.to_csv(csv_filename, index=False)
    print(f"✅ Exported all activities to {csv_filename} upto {timestamp}")
# %%


if __name__ == "__main__":
    main()
