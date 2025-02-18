<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:slsEdData="https://www.sls.fi/ns/digitaledition/metadata/"
	exclude-result-prefixes="xs"
>

	<!--
	XSLT stylesheet: generate-web-xml-est.xsl
	Version 1.0.0
	Author: Sebastian Köhler, Svenska litteratursällskapet i Finland,
		https://www.sls.fi/
	Created: 2025-01-16
	Changes:
		- 2025-01-16: v1.0.0

	Description:
	This XSLT document processes TEI-encoded reading-text documents
	("established" texts) and prepares them for web publication.
	The following transformations are performed on the source document:

	1. <delSpan> elements and their corresponding <anchor> elements are
	   removed.
	2. The positions of <anchor> end tags of comments are corrected.
	3. Transpositions are performed.
	4. Line beginning elements indicating word or line breaks are
	   removed.
	5. Sequential numbering is added to paragraphs and lines.
	6. Metadata is added based on input parameters.

	See the documentation for the individual modules for further details.

	Nodes not affected by the transformations in the aforementioned
	modules will be preserved in the output.

	Usage:
	Set input parameters on the XSLT processor (see `add-metadata.xsl`)
	and execute the transformation on a TEI-encoded XML source document.

	Output:
	A modified TEI-encoded XML document.
	-->

	<xsl:output method="xml" version="1.0" indent="no" encoding="UTF-8" omit-xml-declaration="no"/>

	<!-- Import modules -->
	<xsl:import href="../modules/remove-delspans.xsl"/>
	<xsl:import href="../modules/move-comment-anchors.xsl"/>
	<xsl:import href="../modules/transpose.xsl"/>
	<xsl:import href="../modules/process-lb-breaks.xsl"/>
	<xsl:import href="../modules/add-numbering.xsl"/>
	<xsl:import href="../modules/add-metadata.xsl"/>

	<!-- Entry point -->
	<xsl:template match="/">
		<!-- Pass 1: Remove delSpan-elements -->
		<xsl:variable name="pass1-result">
			<xsl:apply-templates select="/" mode="remove-delspans"/>
		</xsl:variable>

		<!-- Pass 2: Move anchor-elements related to comments -->
		<xsl:variable name="pass2-result">
			<xsl:apply-templates select="$pass1-result" mode="move-comment-anchors"/>
		</xsl:variable>

		<!-- Pass 3: Transpose elements -->
		<xsl:variable name="pass3-result">
			<xsl:apply-templates select="$pass2-result" mode="transpose"/>
		</xsl:variable>

		<!-- Pass 4: Process lb breaks -->
		<xsl:variable name="pass4-result">
			<xsl:apply-templates select="$pass3-result" mode="remove-lb-breaks"/>
		</xsl:variable>

		<!-- Pass 5: Add paragraph/line numbering -->
		<xsl:variable name="pass5-result">
			<xsl:apply-templates select="$pass4-result" mode="add-numbering"/>
		</xsl:variable>

		<!-- Pass 6: Add metadata -->
		<xsl:variable name="pass6-result">
			<xsl:apply-templates select="$pass5-result" mode="add-metadata"/>
		</xsl:variable>

		<!-- Output the final result -->
		<xsl:sequence select="$pass6-result"/>
	</xsl:template>

</xsl:stylesheet>