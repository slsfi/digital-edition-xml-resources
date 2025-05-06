<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
	<title>ISO Schematron rules</title>
	<!-- This file generated 2025-02-07T21:51:31Z by 'extract-isosch.xsl'. -->
	<!-- ********************* -->
	<!-- namespaces, declared: -->
	<!-- ********************* -->
	<ns prefix="tei" uri="http://www.tei-c.org/ns/1.0"/>
	<ns prefix="xs" uri="http://www.w3.org/2001/XMLSchema"/>
	<ns prefix="rng" uri="http://relaxng.org/ns/structure/1.0"/>
	<ns prefix="rna" uri="http://relaxng.org/ns/compatibility/annotations/1.0"/>
	<ns prefix="sch" uri="http://purl.oclc.org/dsdl/schematron"/>
	<ns prefix="sch1x" uri="http://www.ascc.net/xml/schematron"/>
	<!-- ******************************************************* -->
	<!-- constraints in en, und, mul, zxx, of which there are 23 -->
	<!-- ******************************************************* -->
	<pattern id="schematron-constraint-att-datable-w3c-when-1">
		<rule context="tei:*[@when]">
			<report test="@notBefore|@notAfter|@from|@to" role="nonfatal">The @when attribute cannot be used with any other att.datable.w3c attributes.</report>
		</rule>
	</pattern>
	<pattern id="schematron-constraint-att-datable-w3c-from-2">
		<rule context="tei:*[@from]">
			<report test="@notBefore" role="nonfatal">The @from and @notBefore attributes cannot be used together.</report>
		</rule>
	</pattern>
	<pattern id="schematron-constraint-att-datable-w3c-to-3">
		<rule context="tei:*[@to]">
			<report test="@notAfter" role="nonfatal">The @to and @notAfter attributes cannot be used together.</report>
		</rule>
	</pattern>
	<pattern id="schematron-constraint-only_1_ODD_source-4">
		<rule context="tei:*[@source]">
			<let name="srcs" value="tokenize( normalize-space(@source),' ')"/>
			<report test="(   self::tei:classRef                                 | self::tei:dataRef                                 | self::tei:elementRef                                 | self::tei:macroRef                                 | self::tei:moduleRef                                 | self::tei:schemaSpec )                                   and                                   $srcs[2]"> When used on a schema description element (like <value-of select="name(.)"/>), the @source attribute should have only 1 value. (This one has <value-of select="count($srcs)"/>.)</report>
		</rule>
	</pattern>
	<pattern id="schematron-constraint-targetLang-5">
		<rule context="tei:*[not(self::tei:schemaSpec)][@targetLang]">
			<assert test="@target">@targetLang should only be used on <name/> if @target is specified.</assert>
		</rule>
	</pattern>
	<pattern id="schematron-constraint-spanTo-points-to-following-6">
		<rule context="tei:*[ starts-with( @spanTo, '#') ]">
			<assert test="id( substring( @spanTo, 2 ) ) &gt;&gt; ."> The element indicated by @spanTo (<value-of select="@spanTo"/>) must follow the current <name/> element</assert>
		</rule>
	</pattern>
	<pattern id="schematron-constraint-subtypeTyped-7">
		<rule context="tei:*[@subtype]">
			<assert test="@type">The <name/> element should not be categorized in detail with @subtype unless also categorized in general with @type</assert>
		</rule>
	</pattern>
	<pattern id="schematron-constraint-abstractModel-structure-p-in-ab-or-p-8">
		<rule context="tei:p">
			<report test="(ancestor::tei:ab or ancestor::tei:p) and                        not( ancestor::tei:floatingText                           | parent::tei:exemplum                           | parent::tei:item                           | parent::tei:note                           | parent::tei:q                           | parent::tei:quote                           | parent::tei:remarks                           | parent::tei:said                           | parent::tei:sp                           | parent::tei:stage                           | parent::tei:cell                           | parent::tei:figure )"> Abstract model violation: Paragraphs may not occur inside other paragraphs or ab elements.</report>
		</rule>
	</pattern>
	<pattern id="schematron-constraint-abstractModel-structure-p-in-l-9">
		<rule context="tei:l//tei:p">
			<assert test="ancestor::tei:floatingText | parent::tei:figure | parent::tei:note"> Abstract model violation: Metrical lines may not contain higher-level structural elements such as div, p, or ab, unless p is a child of figure or note, or is a descendant of floatingText.</assert>
		</rule>
	</pattern>
	<pattern id="schematron-constraint-ptrAtts-10">
		<rule context="tei:ptr">
			<report test="@target and @cRef">Only one of the attributes @target and @cRef may be supplied on <name/>.</report>
		</rule>
	</pattern>
	<pattern id="schematron-constraint-refAtts-11">
		<rule context="tei:ref">
			<report test="@target and @cRef">Only one of the attributes @target and @cRef may be supplied on <name/>.</report>
		</rule>
	</pattern>
	<pattern id="schematron-constraint-gloss-list-must-have-labels-12">
		<rule context="tei:list[@type='gloss']">
			<assert test="tei:label">The content of a "gloss" list should include a sequence of one or more pairs of a label element followed by an item element</assert>
		</rule>
	</pattern>
	<pattern id="schematron-constraint-abstractModel-structure-l-in-l-13">
		<rule context="tei:l">
			<report test="ancestor::tei:l[not(.//tei:note//tei:l[. = current()])]">Abstract model violation: Lines may not contain lines or lg elements.</report>
		</rule>
	</pattern>
	<pattern id="schematron-constraint-atleast1oflggapl-14">
		<rule context="tei:lg">
			<assert test="count(descendant::tei:lg|descendant::tei:l|descendant::tei:gap) &gt; 0">An lg element must contain at least one child l, lg, or gap element.</assert>
		</rule>
	</pattern>
	<pattern id="schematron-constraint-abstractModel-structure-lg-in-l-15">
		<rule context="tei:lg">
			<report test="ancestor::tei:l[not(.//tei:note//tei:lg[. = current()])]">Abstract model violation: Lines may not contain line groups.</report>
		</rule>
	</pattern>
	<pattern id="schematron-constraint-abstractModel-structure-div-in-l-16">
		<rule context="tei:l//tei:div">
			<assert test="ancestor::tei:floatingText"> Abstract model violation: Metrical lines may not contain higher-level structural elements such as div, unless div is a descendant of floatingText.</assert>
		</rule>
	</pattern>
	<pattern id="schematron-constraint-abstractModel-structure-div-in-ab-or-p-17">
		<rule context="tei:div">
			<report test="(ancestor::tei:p or ancestor::tei:ab) and not(ancestor::tei:floatingText)"> Abstract model violation: p and ab may not contain higher-level structural elements such as div, unless div is a descendant of floatingText.</report>
		</rule>
	</pattern>
	<pattern id="schematron-constraint-abstractModel-structure-ab-in-l-18">
		<rule context="tei:l//tei:ab">
			<assert test="ancestor::tei:floatingText | parent::tei:figure | parent::tei:note"> Abstract model violation: Metrical lines may not contain higher-level divisions such as p or ab, unless ab is a child of figure or note, or is a descendant of floatingText.</assert>
		</rule>
	</pattern>
	<pattern id="schematron-constraint-addSpan-requires-spanTo-19">
		<rule context="tei:addSpan">
			<assert test="@spanTo">The @spanTo attribute of <name/> is required.</assert>
		</rule>
	</pattern>
	<pattern id="schematron-constraint-delSpan-requires-spanTo-21">
		<rule context="tei:delSpan">
			<assert test="@spanTo">The @spanTo attribute of <name/> is required.</assert>
		</rule>
	</pattern>
	<pattern id="schematron-constraint-substContents1-23">
		<rule context="tei:subst">
			<assert test="child::tei:add and (child::tei:del or child::tei:surplus)">
				<name/> must have at least one child add and at least one child del or surplus</assert>
		</rule>
	</pattern>
	<pattern id="schematron-constraint-one_ms_singleton_max-24">
		<rule context="tei:msContents|tei:physDesc|tei:history|tei:additional"> <!-- Note: This rule applies to <msContents>, <physDesc>,
             <history>, and <additional> wherever they occur. Luckily
             they are only allowed in places where they are
             constrained to 0 or 1 occurence. If that changes someday,
             this constraint may will likely need to be updated,
             too. --> <!-- Also worth noting that
             a) if & when we can use abstract patterns, this would be
             better handled as a single abstract rule somewhere, and
             concrete rules in the individual <elementSpec>s; and
             b) I did not test for the existence of "../*[name(.) eq
             $gi][2]" because then an error would be generated for
             each of the multiple occurences of $gi. -->
			<let name="gi" value="name(.)"/>
			<report test="preceding-sibling::*[ name(.) eq $gi ]                           and                           not( following-sibling::*[ name(.) eq $gi ] )"> Only one <name/> is allowed as a child of <value-of select="name(..)"/>.</report>
		</rule>
	</pattern>
	<pattern id="schematron-constraint-msId_minimal-25">
		<rule context="tei:msIdentifier">
			<report test="not( parent::tei:msPart )                           and                           ( child::*[1]/self::idno  or  child::*[1]/self::altIdentifier  or  normalize-space(.) eq '')">An msIdentifier must contain either a repository or location.</report>
		</rule>
	</pattern>

	<!-- ADDITIONAL CONSTRAINTS BASED ON SLS TEXT ENCODING GUIDELINES -->
	<pattern id="check-letter-has-correspdesc">
		<rule context="/tei:TEI">
			<!-- Assert that if there is a <tei:div> or <tei:text> with @type="letter", then <tei:correspDesc> must be in /tei:teiHeader/tei:profileDesc -->
			<assert test="not((//tei:div[@type='letter'] or //tei:text[@type='letter']) and not(tei:teiHeader/tei:profileDesc/tei:correspDesc))">
				If the document contains a div or text-element with @type="letter", it must also contain a correspDesc-element within /tei:teiHeader/tei:profileDesc with metadata about the letter.
			</assert>
		</rule>
	</pattern>
	<pattern id="only-one-genre-type-term-in-textclass">
		<rule context="tei:textClass/tei:keywords">
			<!-- Assert that there is a maximum of one <tei:term> with @type="genre" in /tei:teiHeader/tei:profileDesc/tei:textClass/tei:keywords -->
			<assert test="count(/descendant::tei:term[@type='genre']) le 1">
				The keywords-element in textClass cannot contain more than one term-element with a type-attribute value of "genre".
			</assert>
		</rule>
	</pattern>
	<pattern id="unique-transpose-pointer-targets">
		<rule context="tei:transpose">
			<assert test="count(tei:ptr/@target) = count(distinct-values(tei:ptr/@target))">
				The @target values in ptr-elements in each transpose-element must be unique.
			</assert>
		</rule>
	</pattern>
	<pattern id="no-cross-group-duplicate-ptr-targets">
		<rule context="tei:transpose">
			<let name="myTargets" value="tei:ptr/@target"/>
			<let name="otherTargets" value="../tei:transpose[. != current()]/tei:ptr/@target"/>
			<assert test="empty($myTargets[. = $otherTargets])">
				The @target values of ptr-elements in this transpose-element must not be used in other transpose-elements.
			</assert>
		</rule>
	</pattern>
</schema>
