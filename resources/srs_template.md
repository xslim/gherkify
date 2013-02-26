# {{app_name}} Requirements Specification

# Introduction

# Assumptions

# Overall Description

# External Interface Requirements

# System Features

ui_elements_diagram
# UI Screens and Actions
Possible diagram of interconnection between screens and actions
{{#if yuml}}
``` yuml class
{{{yuml}}}
```
{{/if}}

# Use Cases
{{#each use_cases}}

## {{name}}
{{#if image}}![{{name}}]({{image}}){{/if}}
{{#if yuml}}
``` yuml usecase
{{{yuml}}}
```
{{/if}}

{{#if gherkin}}
``` gherkin
{{{gherkin}}}
```
{{/if}}
  
  {{#each scenarios}}
### {{name}}
{{#if image}}![{{name}}]({{image}}){{/if}}
{{#if yuml}}
``` yuml activity
{{{yuml}}}
```
  {{/if}}

  {{/each}}

{{/each}}

# Other Nonfunctional Requirements

# Other Requirements

# Appendix A: Glossary

# Appendix B: Analysis Models

# Appendix C: To Be Determined List