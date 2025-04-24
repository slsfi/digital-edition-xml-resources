<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:xml="http://www.w3.org/XML/1998/namespace"
	exclude-result-prefixes="tei"
	expand-text="yes"
>

	<!-- ******************************************************************
	*
	*    XSLT stylesheet: process-comment-notes.xsl
	*    Version: 1.0.0
	*    Author:  Sebastian Köhler, Svenska litteratursällskapet i Finland,
	*             https://www.sls.fi/
	*    Created: 2025-01-17
	*    Licence: CC-BY-NC 4.0 (Attribution-NonCommercial 4.0
	*             International),
	*             https://creativecommons.org/licenses/by-nc/4.0/
	*
	*    Changes:
	*        v1.0.0 (2025-01-17)
	*
	*    Description:
	*        This module transforms one or more incoming <note> elements
	*        (which are in no namespace and contain minimal HTML-like
	*        markup) to TEI XML in the http://www.tei-c.org/ns/1.0
	*        namespace.
	*
	*    Key features:
	*        - All <note> elements are wrapped in <note> with updated
	*          @xml:id and @target attributes (e.g., "en123" and
	*          "#start123").
	*        - Certain child elements (<notePosition>, <noteLemma>,
	*          <lemmaBreak>, <noteText>) become <seg> elements with @type
	*          set to their source element name.
	*        - Basic HTML inline elements (<em>, <i>, <sup>, <span> with
	*          @class, etc.) are transformed into TEI elements such as
	*          <hi rend="italics">, <hi rend="superscript">, or custom
	*          <span>-like elements with @rend.
	*        - Unmatched HTML elements (e.g., <p> if no template is
	*          defined) are flattened into text
	*          (on-no-match="text-only-copy"). Their text content is
	*          preserved, but the element node is not retained.
	*        - If you wish to preserve more HTML structure, you must
	*          add more templates. For instance, to preserve <p>, define
	*          a template matching "p" to produce a <p> element in the
	*          TEI namespace.
	*
	*    Usage:
	*        1) Import or include this module in the main XSLT stylesheet.
	*        2) In the main stylesheet, call:
	*           <xsl:apply-templates select="parse-xml-fragment($notes)"
	*                                mode="process-comment-notes"/>
	*           where $notes is a string parameter containing one or more
	*           <note> elements.
	*        3) The resulting transformation outputs TEI <note> elements
	*           (in the TEI namespace) which can be inserted into your
	*           larger TEI document.
	*
	*    Example input:
	*        	<note id="123">
	*        		<notePosition>1–2</notePosition>
	*        		<noteLemma>lemma <lemmaBreak>[...]</lemmaBreak> text</noteLemma>
	*        		<noteText><p>Note <sup><em>text</em></sup> in HTML.</p></noteText>
	*        	</note>
	*
	*    Example output:
	*        	<note xml:id="en123" target="#start123">
	*        		<seg type="notePosition">1–2</seg>
	*        		<seg type="noteLemma">lemma <seg type="lemmaBreak">[...]</seg> text</seg>
	*        		<seg type="noteText">Note <hi rend="superscript"><hi rend="italics">text</hi></hi> in HTML.</seg>
	*        	</note>
	*
	******************************************************************* -->


	<!-- * MODE DECLARATIONS **********************************************
	     * "text-only-copy" for unmatched nodes means that if there is not
	     * a template for a node/an element, it is flattened, meaning that
	     * the element node is stripped but the content is preserved (text)
	     * or further processed (elements). * -->

	<xsl:mode name="process-comment-notes" on-no-match="text-only-copy"/>



	<!-- * TEMPLATES ******************************************************
	     * Observe that the matched elements are in no namespace, but the
	     * target namespace is the TEI namespace. * -->

	<xsl:template match="note" mode="process-comment-notes">
		<xsl:element name="note" namespace="http://www.tei-c.org/ns/1.0">
			<xsl:attribute name="xml:id">end{@id}</xsl:attribute>
			<xsl:attribute name="target">#start{@id}</xsl:attribute>
			<xsl:text>&#10;	</xsl:text> <!-- * Line break and indentation * -->
			<xsl:apply-templates mode="process-comment-notes"/>
		</xsl:element>
	</xsl:template>


	<xsl:template match="notePosition | noteLemma | lemmaBreak | noteText" mode="process-comment-notes">
		<xsl:if test="name() ne 'lemmaBreak'">
			<xsl:text>&#10;	</xsl:text> <!-- * Line break * -->
		</xsl:if>
		<xsl:element name="seg" namespace="http://www.tei-c.org/ns/1.0">
			<xsl:attribute name="type" select="name()"/>
			<xsl:apply-templates mode="process-comment-notes"/>
		</xsl:element>
		<xsl:if test="name() eq 'noteText'">
			<xsl:text>&#10;</xsl:text> <!-- * Line break after closing noteText element * -->
		</xsl:if>
	</xsl:template>


	<xsl:template match="p" mode="process-comment-notes">
		<xsl:if test="preceding-sibling::*[1][self::p]">
		<!-- * Add line breaks if the immediate preceding sibling also i a <p> * -->
			<xsl:element name="lb" namespace="http://www.tei-c.org/ns/1.0"/>
			<xsl:element name="lb" namespace="http://www.tei-c.org/ns/1.0"/>
		</xsl:if>
		<xsl:apply-templates mode="process-comment-notes"/>
	</xsl:template>


	<xsl:template match="em | i" mode="process-comment-notes">
		<xsl:element name="hi" namespace="http://www.tei-c.org/ns/1.0">
			<xsl:attribute name="rend" select="'italics'"/>
			<xsl:apply-templates mode="process-comment-notes"/>
		</xsl:element>
	</xsl:template>


	<xsl:template match="br" mode="process-comment-notes">
		<xsl:element name="lb" namespace="http://www.tei-c.org/ns/1.0"/>
	</xsl:template>


	<xsl:template match="sup" mode="process-comment-notes">
		<xsl:element name="hi" namespace="http://www.tei-c.org/ns/1.0">
			<xsl:attribute name="rend" select="'superscript'"/>
			<xsl:apply-templates mode="process-comment-notes"/>
		</xsl:element>
	</xsl:template>


	<xsl:template match="span" mode="process-comment-notes">
		<xsl:variable name="classNames" select="tokenize(@class)"/>
		<xsl:choose>
			<xsl:when test="count($classNames) gt 1">
				<xsl:element name="{$classNames[1]}" namespace="http://www.tei-c.org/ns/1.0">
					<xsl:attribute name="rend">{$classNames[2]}</xsl:attribute>
					<xsl:apply-templates mode="process-comment-notes"/>
				</xsl:element>
			</xsl:when>
			<xsl:when test="count($classNames) gt 0">
				<xsl:element name="{$classNames[1]}" namespace="http://www.tei-c.org/ns/1.0">
					<xsl:apply-templates mode="process-comment-notes"/>
				</xsl:element>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates mode="process-comment-notes"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template match="a" mode="process-comment-notes">
		<xsl:variable name="classNames" select="tokenize(@class)"/>
		<xsl:choose>
			<xsl:when test="$classNames = 'anchor'">
				<xsl:element name="anchor" namespace="http://www.tei-c.org/ns/1.0">
					<xsl:if test="@name">
						<xsl:attribute name="xml:id">{@name}</xsl:attribute>
					</xsl:if>
				</xsl:element>
			</xsl:when>
			<xsl:when test="count($classNames) gt 0">
				<xsl:element name="{$classNames[1]}" namespace="http://www.tei-c.org/ns/1.0">
					<xsl:if test="count($classNames) gt 1">
						<xsl:attribute name="type">{$classNames[2]}</xsl:attribute>
					</xsl:if>
					<xsl:if test="@href">
						<xsl:attribute name="target">{@href}</xsl:attribute>
					</xsl:if>
					<xsl:apply-templates mode="process-comment-notes"/>
				</xsl:element>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates mode="process-comment-notes"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>