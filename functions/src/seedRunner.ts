#!/usr/bin/env node

/**
 * Standalone script to run seed data
 * Usage: npm run seed
 */

import * as admin from "firebase-admin";
import {seedTestData, cleanupTestData} from "./seedData";

// Initialize Firebase Admin
// eslint-disable-next-line @typescript-eslint/no-var-requires
const serviceAccount = require("../serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

// Parse command line arguments
const args = process.argv.slice(2);
const command = args[0] || "seed";

async function main() {
  try {
    if (command === "seed") {
      await seedTestData();
    } else if (command === "cleanup") {
      await cleanupTestData();
    } else {
      console.log("Usage:");
      console.log("  npm run seed        - Create test data");
      console.log("  npm run seed:clean  - Remove test data");
    }
    process.exit(0);
  } catch (error) {
    console.error("Error:", error);
    process.exit(1);
  }
}

main();
