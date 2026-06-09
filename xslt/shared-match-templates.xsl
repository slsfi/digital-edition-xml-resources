<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xml="http://www.w3.org/XML/1998/namespace"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:slsFn="https://www.sls.fi/ns/digitaledition/functions/"
	exclude-result-prefixes="#all"
	expand-text="yes"
>

	<!-- ******************************************************************
	*
	*    XSLT stylesheet: shared-match-templates.xsl
	*
	*    Version: 3.2.0
	*    Author:  Sebastian Köhler, Svenska litteratursällskapet i Finland,
	*             https://www.sls.fi/
	*    Created: 2025-04-24
	*    Licence: CC BY-NC 4.0 (Attribution-NonCommercial 4.0
	*             International),
	*             https://creativecommons.org/licenses/by-nc/4.0/
	*
	*    Changes:
	*        v3.2.0 (2026-06-09)
	*             - Render tei:title inside tei:bibl or tei:witness in
	*               tei:teiHeader as the HTML citation element <cite>.
	*        v3.1.0 (2026-04-16)
	*             - Treat missing @rend on <milestone unit="section"> as
	*               @rend="blankLine".
	*        v3.0.0 (2026-04-16)
	*             - Update <milestone> handling based on changed spec.
	*        v2.0.0 (2025-11-19)
	*             - Remove Swedish phrases from <milestone> output.
	*        v1.0.1 (2025-05-09)
	*             - Handle @hand in <hi>.
	*        v1.0.0 (2025-04-24)
	*
	*    Description:
	*        This XSLT document defines common match templates used by
	*        `est.xsl`, `introduction.xsl`, `ms_changes.xsl` and
	*        `ms_normalized.xsl`.
	*
	*    Dependencies:
	*        The `required-global-variables.xsl`, `shared-functions.xsl`
	*        and `shared-named-templates.xsl` must be imported before
	*        this stylesheet.
	*
	******************************************************************* -->


	<!-- * TEMPLATES ************************************************** -->

	<xsl:template match="tei:teiHeader"/>


	<xsl:template match="tei:body[not(parent::tei:floatingText)]">
	<!-- * Template for <body> elements that are not children of
	     * <floatingText>. If the global parameter $section-id is set,
	     * process only the <div> with matching @xml:id. The content
	     * of <body> is wrapped in <section> if it contains a child
	     * <head>, otherwise in a <div>. @class is set with the @type
	     * of the parent, <text>. Also @xml:id and @xml:lang are
	     * inherited from <text>. Any footnotes either in the whole
	     * <body> or just the processed section-id are appended as a
	     * <section>. * -->
		<xsl:choose>
			<xsl:when test="exists($section-id)">
				<xsl:apply-templates select="//tei:div[@xml:id eq $section-id]"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="class-names" as="xs:string*"
				              select="(if (parent::tei:text[@type])
				                           then parent::tei:text/@type
				                       else 'prose')"/>
				<xsl:variable name="element-name" as="xs:string"
				              select="if (tei:head)
				                          then 'section'
				                      else 'div'"/>

				<xsl:choose>
					<xsl:when test="$element-name eq 'div' and empty($class-names)
					                and not(parent::tei:text[@xml:id])
					                and not(parent::tei:text[@xml:lang])">
						<xsl:apply-templates/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:element name="{$element-name}">
							<xsl:call-template name="set-attr-from-parent-xml-id"/>
							<xsl:call-template name="set-attr-from-parent-xml-lang"/>
							<xsl:call-template name="set-class-attr">
								<xsl:with-param name="class-names"
								                select="$class-names"/>
							</xsl:call-template>

							<xsl:call-template name="wrap-head-opener-in-hgroup">
								<xsl:with-param name="nodes" select="node()"/>
							</xsl:call-template>
						</xsl:element>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>

		<!-- * Process any footnotes so they appear after the main text. * -->
		<xsl:call-template name="list-footnotes">
			<xsl:with-param name="section-id" select="$section-id"/>
		</xsl:call-template>
	</xsl:template>


	<xsl:template match="tei:div">
	<!-- * If the <div> has a <head> child or @type of the <div> is
	     * 'letterpart', wrap in <section>, otherwise in a <div>. However,
	     * a <div> without attributes will not be outputted. The @type
	     * value will be added as a class name to @class, and if the type
	     * changes, the class name 'incorp' will also be added. * -->
		<xsl:variable name="class-names" as="xs:string*"
			select="(@type,
		             if (ancestor::tei:div[@type][1]/@type ne current()/@type
		                 or (parent::tei:body
			                 and ancestor::tei:text/@type ne current()/@type))
			         then 'incorp' else ())"/>
		<xsl:variable name="element-name" as="xs:string"
		              select="if (*[self::tei:head] or (@type eq 'letterpart'))
		                          then 'section'
		                      else 'div'"/>

		<xsl:choose>
			<xsl:when test="$element-name eq 'div' and empty($class-names)
			                and not(@xml:id) and not(@xml:lang)">
				<xsl:apply-templates/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:element name="{$element-name}">
					<xsl:call-template name="set-attr-from-xml-id"/>
					<xsl:call-template name="set-attr-from-xml-lang"/>
					<xsl:call-template name="set-class-attr">
						<xsl:with-param name="class-names" select="$class-names"/>
					</xsl:call-template>

					<xsl:call-template name="wrap-head-opener-in-hgroup">
						<xsl:with-param name="nodes" select="node()"/>
					</xsl:call-template>
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template match="tei:floatingText">
	<!-- * Wrap content in <section> if <floatingText> has a <body> child
	     * with a <head> as its first child, otherwise wrap in <div>. * -->
		<xsl:variable name="element-name" as="xs:string"
		              select="if (tei:body/tei:head[not(preceding-sibling::*)])
		                          then 'section'
		                      else 'div'"/>

		<xsl:element name="{$element-name}">
			<xsl:call-template name="set-class-attr">
				<xsl:with-param name="class-names"
				                select="(if (@type) then @type else 'prose',
				                         'incorp')"/>
			</xsl:call-template>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>


	<xsl:template match="tei:opener">
	<!--* Wrap in a <div> if not part of a grouping which will be wrapped
		* in <hgroup>, otherwise, just apply templates. * -->
		<xsl:choose>
			<xsl:when test="not(current-grouping-key() eq 'hgroup')
			                or (current-grouping-key() eq 'hgroup'
				                and count(current-group()) lt 2)">
				<div class="opener">
					<xsl:apply-templates/>
				</div>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template match="tei:closer | tei:postscript">
		<div class="{local-name()}">
			<xsl:apply-templates/>
		</div>
	</xsl:template>


	<xsl:template match="tei:q[@rend eq 'parIndent']">
		<div class="q parIndent">
			<xsl:apply-templates/>
		</div>
	</xsl:template>


	<xsl:template match="tei:row">
		<tr><xsl:apply-templates/></tr>
	</xsl:template>


	<xsl:template match="tei:pb">
		<xsl:element name="{
			if ((preceding-sibling::* | following-sibling::*)[
			    self::tei:p or self::tei:head or self::tei:lg or self::tei:div
			    or self::tei:table or self::tei:list or self::tei:milestone
			    or self::tei:quote[@type eq 'block']])
			then 'div' else 'span'
		}">
			<xsl:call-template name="set-attr-from-xml-id"/>
			<xsl:call-template name="set-class-attr">
				<xsl:with-param name="class-names"
				                select="('pb',
				                         @type,
				                         if (@type eq 'author'
				                             or @type eq 'facs'
				                             or @type eq 'other'
				                             or not(@type))
				                             then 'orig' else ())"/>
			</xsl:call-template>
			<xsl:attribute name="role">doc-pagebreak</xsl:attribute>
			<xsl:variable name="delimiter"
			              select="if (empty(@subtype)) then '|' else '['"/>
			<xsl:text>{$delimiter}{@n}{if ($delimiter eq '|')
			                               then '|' else ']'}</xsl:text>
		</xsl:element>
	</xsl:template>


	<xsl:template match="tei:milestone">
		<xsl:variable name="rend-values" as="xs:string*"
			select="tokenize(@rend)"/>

		<xsl:choose>
			<xsl:when test="$rend-values or @unit eq 'section'">
				<xsl:variable name="first-rend" as="xs:string?"
					select="if ($rend-values) then $rend-values[1] else ()"/>
				<hr class="milestone {if ($first-rend eq 'blankLine' or empty($rend-values)) then 'blank' else $first-rend}"/>
			</xsl:when>
			<xsl:when test="@unit eq 'part' and (@when or @ed)">
				<div class="milestone milestonePart">
					<xsl:call-template name="set-attr-from-xml-id"/>
					<xsl:variable name="milestone-date" as="xs:string?"
					              select="slsFn:format-date-or-year(@when)"/>
					<xsl:variable name="milestone-source" as="xs:string?"
						select="@ed"/>
					<xsl:text>{if ($milestone-source) then $milestone-source else ''}{if ($milestone-source and $milestone-date) then ' ' else ''}{if ($milestone-date) then $milestone-date else ''}</xsl:text>
				</div>
			</xsl:when>
			<xsl:when test="@unit eq 'item' and @n">
				<div class="milestone milestoneItem">
					<xsl:call-template name="set-attr-from-xml-id"/>
					<xsl:text>{@n}</xsl:text>
				</div>
			</xsl:when>
			<xsl:otherwise>
				<hr class="milestone blank"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template match="tei:figure">
		<xsl:choose>
			<xsl:when test="@type eq 'placeholder'">
				<!-- TODO: implement placeholder figure -->
			</xsl:when>
		</xsl:choose>
		<figure>
			<xsl:call-template name="set-attr-from-xml-id"/>
			<xsl:apply-templates/>
		</figure>
	</xsl:template>


	<xsl:template match="tei:graphic">
		<xsl:if test="not(parent::tei:figure[@type eq 'placeholder'])">
			<xsl:variable name="fig-desc"
		                  select="parent::tei:figure/tei:figDesc"/>
			<img src="{@url}" loading="lazy" alt="{if ($fig-desc)
			                                           then string($fig-desc)
			                                       else 'illustration'}">
				<xsl:where-populated>
					<xsl:attribute name="height"
						select="translate(@height, 'px', '')"/>
				</xsl:where-populated>
				<xsl:where-populated>
					<xsl:attribute name="width"
						select="translate(@width, 'px', '')"/>
				</xsl:where-populated>
			</img>
		</xsl:if>
	</xsl:template>


	<!-- * <figDesc> is handled by the template for <graphic>. * -->
	<xsl:template match="tei:figDesc"/>


	<xsl:template match="tei:ptr[@type eq 'mediaCollection']">
		<a class="xreference ref_illustration" rel="nofollow"
		   href="{if (starts-with(@target, '#'))
		              then @target
		          else '#' || @target}">
			<img class="symbol" src="{$icons-base-path}/image_symbol.svg"
			     alt="illustration" loading="lazy"/>
		</a>
	</xsl:template>


	<xsl:template match="tei:date">
		<xsl:choose>
			<xsl:when test="@rend">
				<span>
					<xsl:call-template name="set-class-attr-from-rend"/>
					<xsl:apply-templates/>
				</span>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template match="tei:foreign | tei:hi">
	<!-- * Bold, italics, subscript and superscript rend-values are transformed
	     * into their equivalent HTML elements. Other rend-values become class
	     * names on a <span>. The @lang attribute is applied to the innermost
	     * element. <hi> without @rend is equivalent to a rend value of
	     * italics. * -->
		<xsl:variable name="has-element" as="xs:string*"
		              select="('bold', 'italics', 'subscript', 'superscript')"/>
		<xsl:variable name="rend-values" as="xs:string*"
		              select="normalize-space(@rend) => tokenize()"/>
		<xsl:variable name="to-elements" as="xs:string*"
		              select="$rend-values[. = $has-element]"/>
		<xsl:variable name="other-rend-values" as="xs:string*"
			select="$rend-values[not(. = $has-element)]"/>
		<xsl:variable name="xml-lang" as="xs:string?" select="@xml:lang"/>
		<xsl:variable name="hand-value" as="xs:string?" select="@hand"/>

		<!-- * Dynamically generate the correct wrapping sequence, which can
		     * contain the element names 'sub', 'sup', 'span', 'i' and 'b'.
		     * These are applied in this order, so 'sub' is the innermost
		     * element and 'b' the outermost. * -->
		<xsl:variable name="wrappers" select="(
			if ('subscript' = $to-elements) then 'sub' else (),
			if ('superscript' = $to-elements) then 'sup' else (),
			if (exists($other-rend-values)
			    or ($xml-lang and empty($to-elements)))
			    then 'span' else (),
			if ('italics' = $to-elements
			    or local-name() eq 'hi' and empty($rend-values)) then 'i' else (),
			if ('bold' = $to-elements) then 'b' else ()
		)"/>

		<xsl:iterate select="$wrappers">
			<xsl:param name="content">
				<xsl:apply-templates/>
			</xsl:param>
			<xsl:on-completion>
				<xsl:sequence select="$content"/>
			</xsl:on-completion>

			<xsl:variable name="wrapped-content">
				<xsl:element name="{.}">
					<!-- * Apply @lang only to the first (innermost) element * -->
					<xsl:if test="$xml-lang and position() lt 2">
						<xsl:attribute name="lang" select="$xml-lang"/>
					</xsl:if>
					<!-- * Add @class only if it's a <span> * -->
					<xsl:if test=". eq 'span' and exists($other-rend-values)">
						<xsl:call-template name="set-class-attr">
							<xsl:with-param name="class-names"
								select="($other-rend-values,
								         if ($hand-value)
								             then 'handRend'
								         else ())"/>
						</xsl:call-template>
					</xsl:if>
					<xsl:sequence select="$content"/>
				</xsl:element>
			</xsl:variable>

			<xsl:next-iteration>
				<xsl:with-param name="content" select="$wrapped-content"/>
			</xsl:next-iteration>
		</xsl:iterate>
	</xsl:template>


	<xsl:template match="tei:persName | tei:placeName | tei:rs | tei:title">
		<xsl:choose>
			<!-- tei:title inside tei:bibl or tei:witness in tei:teiHeader is
				 rendered as the HTML citation element. -->
			<xsl:when test="local-name() eq 'title' and
							ancestor::tei:teiHeader and
				            (parent::tei:bibl or parent::tei:witness)">
				<cite>
					<xsl:call-template name="set-attr-from-xml-lang"/>
					<xsl:apply-templates/>
				</cite>
			</xsl:when>
			<xsl:otherwise>
				<!-- TODO: tei:title elements should be rendered as the HTML
				     citation element <cite>. -->
				<span>
					<xsl:call-template name="set-class-attr">
						<xsl:with-param name="class-names"
						                select="('tooltiptrigger',
						                         if (local-name() eq 'placeName')
						                             then 'placeName ttPlace'
						                         else if (local-name() eq 'title')
						                             then 'title ttTitle'
						                         else 'person ttPerson',
						                         @rend,
						                         if (@cert eq 'low')
						                             then 'uncertain' else (),
						                         if (@role eq 'fictional')
						                             then 'fictional' else ())"/>
					</xsl:call-template>
					<xsl:call-template name="set-attr-from-key"/>
					<xsl:call-template name="set-attr-from-xml-lang"/>
					<xsl:apply-templates/>
				</span>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template match="tei:ref | tei:ptr[not(@type)]">
	<!-- TODO: Hyperlinks should only used for navigation to real URLs.
	     Should be using a <button> when not navigating to a URL. -->
		<a>
			<xsl:call-template name="set-class-attr">
				<xsl:with-param name="class-names"
				                select="('xreference',
				                         if (not(@type) or @type eq 'url')
				                             then 'ref_external'
				                         else 'ref_' || @type)"/>
			</xsl:call-template>
			<xsl:attribute name="href" select="@target"/>
			<xsl:if test="@type and @type ne 'url'">
				<xsl:attribute name="rel" select="'nofollow'"/>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="local-name() eq 'ref'">
					<xsl:apply-templates/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>{@target}</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</a>
	</xsl:template>

</xsl:stylesheet>