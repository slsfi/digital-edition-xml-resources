<?xml version="1.0" encoding="utf-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
   <title>ISO Schematron rules</title>
   <!-- This file generated 2024-12-09T11:59:27Z by 'extract-isosch.xsl'. -->

   <!-- ********************* -->
   <!-- namespaces, declared: -->
   <!-- ********************* -->
   <ns prefix="tei" uri="http://www.tei-c.org/ns/1.0"/>
   <ns prefix="xs" uri="http://www.w3.org/2001/XMLSchema"/>
   <ns prefix="rng" uri="http://relaxng.org/ns/structure/1.0"/>
   <ns prefix="rna" uri="http://relaxng.org/ns/compatibility/annotations/1.0"/>
   <ns prefix="sch" uri="http://purl.oclc.org/dsdl/schematron"/>
   <ns prefix="sch1x" uri="http://www.ascc.net/xml/schematron"/>

   <!-- ********************* -->
   <!-- namespaces, implicit: -->
   <!-- ********************* -->


   <!-- ************ -->
   <!-- constraints: -->
   <!-- ************ -->
   <pattern id="schematron-constraint-tei_sls_master-att.datable.w3c-att-datable-w3c-when-1">
      <rule context="tei:*[@when]">
        <report test="@notBefore|@notAfter|@from|@to" role="nonfatal">The @when attribute cannot be used with any other att.datable.w3c attributes.</report>
      </rule>
    </pattern>
   <pattern id="schematron-constraint-tei_sls_master-att.datable.w3c-att-datable-w3c-from-2">
      <rule context="tei:*[@from]">
        <report test="@notBefore" role="nonfatal">The @from and @notBefore attributes cannot be used together.</report>
      </rule>
    </pattern>
   <pattern id="schematron-constraint-tei_sls_master-att.datable.w3c-att-datable-w3c-to-3">
      <rule context="tei:*[@to]">
        <report test="@notAfter" role="nonfatal">The @to and @notAfter attributes cannot be used together.</report>
      </rule>
    </pattern>
   <pattern id="schematron-constraint-tei_sls_master-att.global.source-source-only_1_ODD_source-4">
          <rule context="tei:*[@source]">
            <let name="srcs" value="tokenize( normalize-space(@source),' ')"/>
            <report test="( self::tei:classRef               | self::tei:dataRef               | self::tei:elementRef               | self::tei:macroRef               | self::tei:moduleRef               | self::tei:schemaSpec )               and               $srcs[2]">
              When used on a schema description element (like
              <value-of select="name(.)"/>), the @source attribute
              should have only 1 value. (This one has <value-of select="count($srcs)"/>.)
            </report>
          </rule>
        </pattern>
   <pattern id="schematron-constraint-tei_sls_master-att.typed-subtypeTyped-5">
      <rule context="tei:*[@subtype]">
        <assert test="@type">The <name/> element should not be categorized in detail with @subtype unless also categorized in general with @type</assert>
      </rule>
    </pattern>
   <pattern id="schematron-constraint-tei_sls_master-att.pointing-targetLang-6">
          <rule context="tei:*[not(self::tei:schemaSpec)][@targetLang]">
            <assert test="@target">@targetLang should only be used on <name/> if @target is specified.</assert>
          </rule>
        </pattern>
   <pattern id="schematron-constraint-tei_sls_master-att.spanning-spanTo-spanTo-points-to-following-7">
          <rule context="tei:*[@spanTo]">
            <assert test="id(substring(@spanTo,2)) and following::*[@xml:id=substring(current()/@spanTo,2)]">
The element indicated by @spanTo (<value-of select="@spanTo"/>) must follow the current element <name/>
            </assert>
          </rule>
        </pattern>
   <pattern id="schematron-constraint-tei_sls_master-p-abstractModel-structure-p-in-ab-or-p-8">
      <rule context="tei:p">
        <report test="(ancestor::tei:ab or ancestor::tei:p) and                        not( ancestor::tei:floatingText                           | parent::tei:exemplum                           | parent::tei:item                           | parent::tei:note                           | parent::tei:q                           | parent::tei:quote                           | parent::tei:remarks                           | parent::tei:said                           | parent::tei:sp                           | parent::tei:stage                           | parent::tei:cell                           | parent::tei:figure )">
          Abstract model violation: Paragraphs may not occur inside other paragraphs or ab elements.
        </report>
      </rule>
    </pattern>
   <pattern id="schematron-constraint-tei_sls_master-p-abstractModel-structure-p-in-l-or-lg-9">
      <rule context="tei:p">
        <report test="( ancestor::tei:l  or  ancestor::tei:lg ) and                        not( ancestor::tei:floatingText                           | parent::tei:figure                           | parent::tei:note )">
          Abstract model violation: Lines may not contain higher-level structural elements such as div, p, or ab, unless p is a child of figure or note, or is a descendant of floatingText.
        </report>
      </rule>
    </pattern>
   <pattern id="schematron-constraint-tei_sls_master-name-calendar-check-name-10">
                <rule context="tei:*[@calendar]">
                    <assert test="string-length( normalize-space(.) ) gt 0"> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <name/> element has no textual content.</assert>
                </rule>
            </pattern>
   <pattern id="schematron-constraint-tei_sls_master-ptr-ptrAtts-11">
      <rule context="tei:ptr">
        <report test="@target and @cRef">Only one of the attributes @target and @cRef may be supplied on <name/>.</report>
      </rule>
    </pattern>
   <pattern id="schematron-constraint-tei_sls_master-ref-refAtts-12">
      <rule context="tei:ref">
        <report test="@target and @cRef">Only one of the attributes @target' and @cRef' may be supplied on <name/>
         </report>
      </rule>
    </pattern>
   <pattern id="schematron-constraint-tei_sls_master-list-gloss-list-must-have-labels-13">
      <rule context="tei:list[@type='gloss']">
	        <assert test="tei:label">The content of a "gloss" list should include a sequence of one or more pairs of a label element followed by an item element</assert>
      </rule>
    </pattern>
   <pattern id="schematron-constraint-tei_sls_master-author-calendar-check-author-14">
                <rule context="tei:*[@calendar]">
                    <assert test="string-length( normalize-space(.) ) gt 0"> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <name/> element has no textual content.</assert>
                </rule>
            </pattern>
   <pattern id="schematron-constraint-tei_sls_master-resp-calendar-check-resp-15">
                <rule context="tei:*[@calendar]">
                    <assert test="string-length( normalize-space(.) ) gt 0"> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <name/> element has no textual content.</assert>
                </rule>
            </pattern>
   <pattern id="schematron-constraint-tei_sls_master-title-calendar-check-title-16">
                <rule context="tei:*[@calendar]">
                    <assert test="string-length( normalize-space(.) ) gt 0"> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <name/> element has no textual content.</assert>
                </rule>
            </pattern>
   <pattern id="schematron-constraint-tei_sls_master-l-abstractModel-structure-l-in-l-17">
      <rule context="tei:l">
        <report test="ancestor::tei:l[not(.//tei:note//tei:l[. = current()])]">Abstract model violation: Lines may not contain lines or lg elements.</report>
      </rule>
    </pattern>
   <pattern id="schematron-constraint-tei_sls_master-lg-atleast1oflggapl-18">
      <rule context="tei:lg">
        <assert test="count(descendant::tei:lg|descendant::tei:l|descendant::tei:gap) &gt; 0">An lg element must contain at least one child l, lg, or gap element.</assert>
      </rule>
    </pattern>
   <pattern id="schematron-constraint-tei_sls_master-lg-abstractModel-structure-lg-in-l-19">
      <rule context="tei:lg">
        <report test="ancestor::tei:l[not(.//tei:note//tei:lg[. = current()])]">Abstract model violation: Lines may not contain line groups.</report>
      </rule>
    </pattern>
   <pattern id="schematron-constraint-tei_sls_master-idno-calendar-check-idno-20">
                <rule context="tei:*[@calendar]">
                    <assert test="string-length( normalize-space(.) ) gt 0"> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <name/> element has no textual content.</assert>
                </rule>
            </pattern>
   <pattern id="schematron-constraint-tei_sls_master-licence-calendar-check-licence-21">
                <rule context="tei:*[@calendar]">
                    <assert test="string-length( normalize-space(.) ) gt 0"> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <name/> element has no textual content.</assert>
                </rule>
            </pattern>
   <pattern id="schematron-constraint-tei_sls_master-change-calendar-check-change-22">
                <rule context="tei:*[@calendar]">
                    <assert test="string-length( normalize-space(.) ) gt 0"> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <name/> element has no textual content.</assert>
                </rule>
            </pattern>
      
      
    
      
      
    
      
      
    <pattern id="schematron-constraint-tei_sls_master-div-abstractModel-structure-div-in-l-or-lg-26">
      <rule context="tei:div">
        <report test="(ancestor::tei:l or ancestor::tei:lg) and not(ancestor::tei:floatingText)">
          Abstract model violation: Lines may not contain higher-level structural elements such as div, unless div is a descendant of floatingText.
        </report>
      </rule>
    </pattern>
   <pattern id="schematron-constraint-tei_sls_master-div-abstractModel-structure-div-in-ab-or-p-27">
      <rule context="tei:div">
        <report test="(ancestor::tei:p or ancestor::tei:ab) and not(ancestor::tei:floatingText)">
          Abstract model violation: p and ab may not contain higher-level structural elements such as div, unless div is a descendant of floatingText.
        </report>
      </rule>
    </pattern>
   <pattern id="schematron-constraint-tei_sls_master-ab-abstractModel-structure-ab-in-l-or-lg-28">
      <rule context="tei:ab">
        <report test="(ancestor::tei:l or ancestor::tei:lg) and not( ancestor::tei:floatingText |parent::tei:figure |parent::tei:note )">
          Abstract model violation: Lines may not contain higher-level divisions such as p or ab, unless ab is a child of figure or note, or is a descendant of floatingText.
        </report>
      </rule>
    </pattern>
   <pattern id="schematron-constraint-tei_sls_master-addSpan-addSpan-requires-spanTo-29">
      <rule context="tei:addSpan">
        <assert test="@spanTo">The @spanTo attribute of <name/> is required.</assert>
      </rule>
    </pattern>
   <pattern id="schematron-constraint-tei_sls_master-delSpan-delSpan-requires-spanTo-31">
      <rule context="tei:delSpan">
        <assert test="@spanTo">The @spanTo attribute of <name/> is required.</assert>
      </rule>
    </pattern>
   <pattern id="schematron-constraint-tei_sls_master-subst-substContents1-33">
      <rule context="tei:subst">
        <assert test="child::tei:add and (child::tei:del or child::tei:surplus)">
            <name/> must have at least one child add and at least one child del or surplus</assert>
      </rule>
    </pattern>
   <pattern id="schematron-constraint-tei_sls_master-persName-calendar-check-persName-34">
                <rule context="tei:*[@calendar]">
                    <assert test="string-length( normalize-space(.) ) gt 0"> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <name/> element has no textual content.</assert>
                </rule>
            </pattern>
   <pattern id="schematron-constraint-tei_sls_master-placeName-calendar-check-placeName-35">
                <rule context="tei:*[@calendar]">
                    <assert test="string-length( normalize-space(.) ) gt 0"> @calendar indicates one or more
                        systems or calendars to which the date represented by the content of this element belongs,
                        but this <name/> element has no textual content.</assert>
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
</schema>
