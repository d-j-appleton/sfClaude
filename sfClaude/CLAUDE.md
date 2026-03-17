# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Salesforce DX (SFDX)** project targeting API version **66.0**. It uses the standard `force-app` package directory layout with Lightning Web Components (LWC), Aura components, Apex classes, and standard Salesforce metadata.

## Commands

### Development & Deployment
```bash
# Authenticate to a Salesforce org
sf org login web --alias <alias>

# Push source to scratch org
sf project deploy start

# Pull source from org
sf project retrieve start

# Run anonymous Apex
sf apex run --file scripts/apex/hello.apex

# Run SOQL query
sf data query --file scripts/soql/account.soql
```

### Testing
```bash
# Run all LWC Jest unit tests
npm test

# Run tests in watch mode
npm run test:unit:watch

# Run tests with coverage
npm run test:unit:coverage

# Run a single test file
npx jest path/to/component/__tests__/component.test.js

# Run Apex tests in org
sf apex run test --test-level RunLocalTests
```

### Linting & Formatting
```bash
# Lint Aura and LWC JavaScript
npm run lint

# Format all files (Apex, XML, HTML, JS, etc.)
npm run prettier

# Verify formatting without making changes
npm run prettier:verify
```

## Architecture

### Directory Structure
```
force-app/main/default/
├── classes/          # Apex classes (.cls + .cls-meta.xml)
├── triggers/         # Apex triggers (.trigger + .trigger-meta.xml)
├── lwc/              # Lightning Web Components (each component is a folder)
├── aura/             # Aura components
├── objects/          # Custom objects and field definitions
├── flexipages/       # Lightning App Builder pages
├── layouts/          # Page layouts
├── permissionsets/   # Permission sets
├── staticresources/  # Static resources
└── contentassets/    # Content assets
```

### LWC Component Structure
Each LWC component lives in its own folder under `lwc/` and typically contains:
- `componentName.html` — template
- `componentName.js` — controller
- `componentName.js-meta.xml` — metadata/targets
- `__tests__/componentName.test.js` — Jest unit tests

### Code Quality Hooks
Pre-commit hooks (via Husky + lint-staged) automatically run:
- Prettier formatting on staged files
- ESLint on Aura and LWC JS files
- Jest tests on changed LWC components

### Scratch Org Configuration
Scratch org definition is in `config/project-scratch-def.json` — Developer edition with Lightning Experience enabled.
