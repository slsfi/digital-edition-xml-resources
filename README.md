# SLS Digital Edition XML Resources

This repository contains XML resources like schemas and transformation stylesheets for SLS digital edition projects. 

## Content

- `project-schema-validation`: XML validation files for SLS digital edition projects.
- `rng/`: RELAX NG schema files derived from TEI ODD files using [TEI Garage](https://teigarage.tei-c.org/) (converted from ODD Document to RELAX NG schema). An RELAX NG schema describes the structure of an XML document. It is an alternative to XSD.
- `schematron/`: Schematron files derived from TEI ODD files using [TEI Garage](https://teigarage.tei-c.org/) (converted from ODD Document to ISO Schematron constraints). Schematron is used to make assertions about the presence or absence of patterns in XML trees.
- `tei-odd/`: [TEI](https://tei-c.org/) ODD (One Document Does-it-all) files specifying TEI customizations. Contains the "TEI SLS Master" customization, which includes all elements and attributes in use in SLS projects.
- `xsd/`: XML Schema Definition files derived from TEI ODD files using [TEI Garage](https://teigarage.tei-c.org/) (converted from ODD Document to XSD schema). An XML Schema describes the structure of an XML document. It is an alternative to RNG.
- `xslt/`: XSLT stylesheets used by SLS projects for transforming TEI XML documents to HTML and other formats. These should be copied to the project files repositories. See [`xslt/README.md`](xslt/README.md) for further details about the stylesheets.

## Notes

- All modifications should primarily be made to the TEI SLS Master ODD file, which is then converted to Schematron, XSD, and RNG files using [TEI Garage](https://teigarage.tei-c.org/). However, some manual editing of the files might be necessary, so be observant of existing changes when generating new Schematron and XSD files and committing them.
- The file extension of ISO Schematron files served by TEI Garage is `.xml`, but you should save the Schematron files with the `.sch` extension for Oxygen to recognize them.

## Oxygen

For [Oxygen XML Editor](https://www.oxygenxml.com/) to run validation against XML schemas on GitHub, you need to add `raw.githubusercontent.com` to its Trusted Hosts (Options -> Preferences -> Network Connection Settings -> Trusted Hosts). Oxygen will likely suggest adding `raw.githubusercontent.com:443` to its Trusted Hosts the first time you open an XML document with schemas on GitHub, however, the URL needs to be added without the port `:443`.
