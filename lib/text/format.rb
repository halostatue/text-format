# -*- ruby encoding: utf-8 -*-

unless defined?(::Text)
  module Text # :nodoc:
  end
end

# = Introduction
#
# Text::Format provides the ability to nicely format fixed-width text with
# knowledge of the writeable space (number of columns), margins, and
# indentation settings.
class Text::Format
  VERSION = '1.1'

  SPACES_RE   = %r{\s+}mo.freeze
  NEWLINE_RE  = %r{\n}o.freeze
  TAB         = "\t".freeze
  NEWLINE     = "\n".freeze

  # Global common English abbreviations. More can be added with
  # #abbreviations.
  ABBREV = %w(Mr Mrs Ms Jr Sr Dr)

  # Formats text flush to the left margin with a visual and physical ragged
  # right margin.
  #
  #      >A paragraph that is<
  #      >left aligned.<
  LEFT_ALIGN  = :left
  # Formats text flush to the right margin with a visual ragged left margin.
  # The actual left margin is padded with spaces from the beginning of the
  # line to the start of the text such that the right margin will be flush.
  #
  #      >A paragraph that is<
  #      >     right aligned.<
  RIGHT_ALIGN = :right
  # Formats text flush to the left margin with a visual ragged right margin.
  # The line is padded with spaces from the end of the text to the right
  # margin.
  #
  #      >A paragraph that is<
  #      >right filled.      <
  RIGHT_FILL  = :fill
  # Formats the text flush to both the left and right margins. The last line
  # will not be justified if it consists of a single word (it will be
  # treated as +RIGHT_FILL+ in this case). Spacing between words is
  # increased to ensure that the textg is flush with both margins.
  #
  #      |A paragraph  that|
  #      |is     justified.|
  #
  #      |A paragraph  that is|
  #      |justified.          |
  JUSTIFY     = :justify
  # When #hard_margins is enabled, a word that extends over the right margin
  # will be split at the number of characters needed. This is similar to how
  # characters wrap on a terminal. This is the default split mechanism when
  # #hard_margins is enabled.
  #
  #      repre
  #      senta
  #      ion
  SPLIT_FIXED                     = 1
  # When #hard_margins is enabled, a word that extends over the right margin
  # will be split at one less than the number of characters needed with a
  # C-style continuation character (\). If the word cannot be split using
  # the rules of SPLIT_CONTINUATION, and the word will not fit wholly into
  # the next line, then SPLIT_FIXED will be used.
  #
  #       repr\
  #       esen\
  #       tati\
  #       on
  SPLIT_CONTINUATION              = 2
  # When #hard_margins is enabled, a word that extends over the right margin
  # will be split according to the hyphenator specified by the #hyphenator
  # object; if there is no hyphenation library supplied, then the hyphenator
  # of Text::Format itself is used, which is the same as SPLIT_CONTINUATION.
  # See #hyphenator for more information about hyphenation libraries. The
  # example below is valid with Text::Hyphen. If the word cannot be split
  # using the hyphenator's rules, and the word will not fit wholly into the
  # next line, then SPLIT_FIXED will be used.
  #
  #       rep-
  #       re-
  #       sen-
  #       ta-
  #       tion
  #
  SPLIT_HYPHENATION               = 4
  # When #hard_margins is enabled, a word that extends over the right margin
  # will be split at one less than the number of characters needed with a
  # C-style continuation character (\). If the word cannot be split using
  # the rules of SPLIT_CONTINUATION, then SPLIT_FIXED will be used.
  SPLIT_CONTINUATION_FIXED        = SPLIT_CONTINUATION | SPLIT_FIXED
  # When #hard_margins is enabled, a word that extends over the right margin
  # will be split according to the hyphenator specified by the #hyphenator
  # object; if there is no hyphenation library supplied, then the hyphenator
  # of Text::Format itself is used, which is the same as SPLIT_CONTINUATION.
  # See #hyphenator for more information about hyphenation libraries. The
  # example below is valid with Text::Hyphen. If the word cannot be split
  # using the hyphenator's rules, then SPLIT_FIXED will
  # be used.
  SPLIT_HYPHENATION_FIXED         = SPLIT_HYPHENATION | SPLIT_FIXED
  # Attempts to split words according to the rules of the supplied
  # hyphenator (e.g., SPLIT_HYPHENATION); if the word cannot be split using
  # these rules, then the rules of SPLIT_CONTINUATION will be followed. In
  # all cases, if the word cannot be split using either SPLIT_HYPHENATION or
  # SPLIT_CONTINUATION, and the word will not fit wholly into the next line,
  # then SPLIT_FIXED will be used.
  SPLIT_HYPHENATION_CONTINUATION  = SPLIT_HYPHENATION | SPLIT_CONTINUATION
  # Attempts to split words according to the rules of the supplied
  # hyphenator (e.g., SPLIT_HYPHENATION); if the word cannot be split using
  # these rules, then the rules of SPLIT_CONTINUATION will be followed. In
  # all cases, if the word cannot be split using either SPLIT_HYPHENATION or
  # SPLIT_CONTINUATION, then SPLIT_FIXED will be used.
  SPLIT_ALL                       = SPLIT_HYPHENATION | SPLIT_CONTINUATION | SPLIT_FIXED

  # Words forcibly split by Text::Format will be stored as split words. This
  # class represents a word forcibly split.
  class SplitWord
    # The word that was split.
    attr_reader :word
    # The first part of the word that was split.
    attr_reader :first
    # The remainder of the word that was split.
    attr_reader :rest

    def initialize(word, first, rest)
      @word   = word
      @first  = first
      @rest   = rest
    end
  end

  # Indicates punctuation characters that terminates a sentence, as some
  # English typesetting rules indicate that sentences should be followed by
  # two spaces. This is an archaic rule, but is supported with #extra_space.
  # This is the default set of terminal punctuation characters. Additional
  # terminal punctuation may be added to the formatting object through
  # #terminal_punctuation.
  TERMINAL_PUNCTUATION  = %q(.?!)
  # Indicates quote characters that may follow terminal punctuation under
  # the current formatting rules. This satisfies the English formatting rule
  # that indicates that sentences terminated inside of quotes should have
  # the punctuation inside of the quoted text, not outside of the terminal
  # quote. Additional terminal quotes may be added to the formatting object
  # through #terminal_quotes. See TERMINAL_PUNCTUATION for more information.
  TERMINAL_QUOTES       = %q('")

  # Returns a regular expression for a set of characters (at least one
  # non-whitespace followed by at least one space) of the specified size
  # followed by one or more of any character.
  # RE_BREAK_SIZE = lambda { |size| %r{((?:\S+\s+){#{size}})(.+)] }

  # Compares the formatting rules, excepting #hyphenator, of two
  # Text::Format objects. Generated results (e.g., #split_words) are not
  # compared.
  def ==(o)
    [ :text, :columns, :left_margin, :right_margin, :hard_margins,
      :split_rules, :first_indent, :body_indent, :tag_text, :tabstop,
      :format_style, :extra_space, :tag_paragraph, :nobreak,
      :terminal_punctuation, :terminal_quotes, :abbreviations,
      :nobreak_regex ].all? { |rule|
      self.send(rule) == o.send(rule)
    }
  end

  # The default text to be manipulated. Note that value is optional, but
  # if the formatting functions are called without values, this text is
  # what will be formatted.
  #
  # *Default*::       <tt>[]</tt>
  # <b>Used in</b>::  All methods
  attr_accessor :text

  # The total width of the format area. The margins, indentation, and text
  # are formatted into this space. Any value provided is silently
  # converted to a positive integer.
  #
  #                             COLUMNS
  #  <-------------------------------------------------------------->
  #  <-----------><------><---------------------------><------------>
  #   left margin  indent  text is formatted into here  right margin
  #
  # *Default*::       <tt>72</tt>
  # <b>Used in</b>::  #format, #paragraphs, #center
  attr_accessor :columns
  undef :columns=;
  def columns=(col) #:nodoc:
    @columns = col.to_i.abs
  end

  # The number of spaces used for the left margin. The value provided is
  # silently converted to a positive integer value.
  #
  #                             columns
  #  <-------------------------------------------------------------->
  #  <-----------><------><---------------------------><------------>
  #   LEFT MARGIN  indent  text is formatted into here  right margin
  #
  # *Default*::       <tt>0</tt>
  # <b>Used in</b>::  #format, #paragraphs, #center
  attr_accessor :left_margin
  undef :left_margin=;
  def left_margin=(left) #:nodoc:
    @left_margin = left.to_i.abs
  end

  # The number of spaces used for the right margin. The value provided is
  # silently converted to a positive integer value.
  #
  #                             columns
  #  <-------------------------------------------------------------->
  #  <-----------><------><---------------------------><------------>
  #   left margin  indent  text is formatted into here  RIGHT MARGIN
  #
  # *Default*::       <tt>0</tt>
  # <b>Used in</b>::  #format, #paragraphs, #center
  attr_accessor :right_margin
  undef :right_margin=;
  def right_margin=(right) #:nodoc:
    @right_margin = right.to_i.abs
  end

  # The number of spaces to indent the first line of a paragraph. The
  # value provided is silently converted to a positive integer value.
  #
  #                             columns
  #  <-------------------------------------------------------------->
  #  <-----------><------><---------------------------><------------>
  #   left margin  INDENT  text is formatted into here  right margin
  #
  # *Default*::       <tt>4</tt>
  # <b>Used in</b>::  #format, #paragraphs
  attr_accessor :first_indent
  undef :first_indent=;
  def first_indent=(first) #:nodoc:
    @first_indent = first.to_i.abs
  end

  # The number of spaces to indent all lines after the first line of a
  # paragraph. The value provided is silently converted to a positive
  # integer value.
  #
  #                             columns
  #  <-------------------------------------------------------------->
  #  <-----------><------><---------------------------><------------>
  #   left margin  INDENT  text is formatted into here  right margin
  #
  # *Default*::       <tt>0</tt>
  # <b>Used in</b>::  #format, #paragraphs
  attr_accessor :body_indent
  undef :body_indent=;
  def body_indent=(body) #:nodoc:
    @body_indent = body.to_i.abs
  end

  # Normally, words larger than the format area will be placed on a line
  # by themselves. Setting this value to +true+ will force words larger
  # than the format area to be split into one or more "words" each at most
  # the size of the format area. The first line and the original word will
  # be placed into #split_words. Note that this will cause the output to
  # look *similar* to a #format_style of JUSTIFY. (Lines will be filled as
  # much as possible.)
  #
  # *Default*::       +false+
  # <b>Used in</b>::  #format, #paragraphs
  attr_accessor :hard_margins

  # An array of words split during formatting if #hard_margins is set to
  # +true+.
  #   #split_words << Text::Format::SplitWord.new(word, first, rest)
  attr_reader :split_words

  # The object responsible for hyphenating. It must respond to
  # #hyphenate_to(word, size) or #hyphenate_to(word, size, formatter) and
  # return an array of the word split into two parts (e.g., <tt>[part1,
  # part2]</tt>; if there is a hyphenation mark to be applied,
  # responsibility belongs to the hyphenator object. The size is the MAXIMUM
  # size permitted, including any hyphenation marks.
  #
  # If the #hyphenate_to method has an arity of 3, the current formatter
  # (+self+) will be provided to the method. This allows the hyphenator to
  # make decisions about the hyphenation based on the formatting rules.
  #
  # #hyphenate_to should return <tt>[nil, word]</tt> if the word cannot be
  # hyphenated.
  #
  # *Default*::       +self+ (SPLIT_CONTINUATION)
  # <b>Used in</b>::  #format, #paragraphs
  attr_accessor :hyphenator
  undef :hyphenator=;
  def hyphenator=(h) #:nodoc:
    h ||= self

    raise ArgumentError, "#{h.inspect} is not a valid hyphenator." unless h.respond_to?(:hyphenate_to)
    arity = h.method(:hyphenate_to).arity
    raise ArgumentError, "#{h.inspect} must have exactly two or three arguments." unless arity.between?(2, 3)

    @hyphenator       = h
    @hyphenator_arity = arity
  end

  # Specifies the split mode; used only when #hard_margins is set to +true+.
  # Allowable values are:
  #
  # * +SPLIT_FIXED+
  # * +SPLIT_CONTINUATION+
  # * +SPLIT_HYPHENATION+
  # * +SPLIT_CONTINUATION_FIXED+
  # * +SPLIT_HYPHENATION_FIXED+
  # * +SPLIT_HYPHENATION_CONTINUATION+
  # * +SPLIT_ALL+
  #
  # *Default*::       <tt>Text::Format::SPLIT_FIXED</tt>
  # <b>Used in</b>::  #format, #paragraphs
  attr_accessor :split_rules
  undef :split_rules=;
  def split_rules=(s) #:nodoc:
    raise ArgumentError, "Invalid value provided for #split_rules." if ((s < SPLIT_FIXED) or (s > SPLIT_ALL))
    @split_rules = s
  end

  # Indicates whether sentence terminators should be followed by a single
  # space (+false+), or two spaces (+true+). See #abbreviations for more
  # information.
  #
  # *Default*::       +false+
  # <b>Used in</b>::  #format, #paragraphs
  attr_accessor :extra_space

  # Defines the current abbreviations as an array. This is only used if
  # extra_space is turned on.
  #
  # If one is abbreviating "President" as "Pres." (abbreviations =
  # ["Pres"]), then the results of formatting will be as illustrated in the
  # table below:
  #
  #                         abbreviations
  #   extra_space | #include?("Pres") | not #include?("Pres")
  #   ------------+-------------------+----------------------
  #       true    | Pres. Lincoln     | Pres.  Lincoln
  #       false   | Pres. Lincoln     | Pres. Lincoln
  #   ------------+-------------------+----------------------
  #   extra_space | #include?("Mrs")  | not #include?("Mrs")
  #       true    | Mrs. Lincoln      | Mrs.  Lincoln
  #       false   | Mrs. Lincoln      | Mrs. Lincoln
  #
  # Note that abbreviations should not have the terminal period as part of
  # their definitions.
  #
  # This automatic abbreviation handling *will* cause some issues with
  # uncommon sentence structures. The two sentences below will not be
  # formatted correctly:
  #
  #   You're in trouble now, Mr.
  #   Just wait until your father gets home.
  #
  # Under no circumstances (because Mr is a predefined abbreviation) will
  # this ever be separated by two spaces.
  #
  # *Default*::       <tt>[]</tt>
  # <b>Used in</b>::  #format, #paragraphs
  attr_accessor :abbreviations

  # Specifies additional punctuation characters that terminate a sentence,
  # as some English typesetting rules indicate that sentences should be
  # followed by two spaces. This is an archaic rule, but is supported with
  # #extra_space. This is added to the default set of terminal punctuation
  # defined in TERMINAL_PUNCTUATION.
  #
  # *Default*::       <tt>""</tt>
  # <b>Used in</b>::  #format, #paragraphs
  attr_accessor :terminal_punctuation
  # Specifies additional quote characters that may follow terminal
  # punctuation under the current formatting rules. This satisfies the
  # English formatting rule that indicates that sentences terminated inside
  # of quotes should have the punctuation inside of the quoted text, not
  # outside of the terminal quote. This is added to the default set of
  # terminal quotes defined in TERMINAL_QUOTES.
  #
  # *Default*::       <tt>""</tt>
  # <b>Used in</b>::  #format, #paragraphs
  attr_accessor :terminal_quotes

  # Indicates whether the formatting of paragraphs should be done with
  # tagged paragraphs. Useful only with #tag_text.
  #
  # *Default*::       +false+
  # <b>Used in</b>::  #format, #paragraphs
  attr_accessor :tag_paragraph

  # The text to be placed before each paragraph when #tag_paragraph is
  # +true+. When #format is called, only the first element (#tag_text[0]) is
  # used. When #paragraphs is called, then each successive element
  # (#tag_text[n]) will be used once, with corresponding paragraphs. If the
  # tag elements are exhausted before the text is exhausted, then the
  # remaining paragraphs will not be tagged. Regardless of indentation
  # settings, a blank line will be inserted between all paragraphs when
  # #tag_paragraph is +true+.
  #
  # The Text::Format package provides three number generators,
  # Text::Format::Alpha, Text::Format::Number, and Text::Format::Roman to
  # assist with the numbering of paragraphs.
  #
  # *Default*::       <tt>[]</tt>
  # <b>Used in</b>::  #format, #paragraphs
  attr_accessor :tag_text

  # Indicates whether or not the non-breaking space feature should be used.
  #
  # *Default*::       +false+
  # <b>Used in</b>::  #format, #paragraphs
  attr_accessor :nobreak

  # A hash which holds the regular expressions on which spaces should not be
  # broken. The hash is set up such that the key is the first word and the
  # value is the second word.
  #
  # For example, if +nobreak_regex+ contains the following hash:
  #
  #   { %r{Mrs?\.?} => %r{\S+}, %r{\S+} => %r{(?:[SJ])r\.?} }
  #
  # Then "Mr. Jones", "Mrs Jones", and "Jones Jr." would not be broken. If
  # this simple matching algorithm indicates that there should not be a
  # break at the current end of line, then a backtrack is done until there
  # are two words on which line breaking is permitted. If two such words are
  # not found, then the end of the line will be broken *regardless*. If
  # there is a single word on the current line, then no backtrack is done
  # and the word is stuck on the end.
  #
  # *Default*::       <tt>{}</tt>
  # <b>Used in</b>::  #format, #paragraphs
  attr_accessor :nobreak_regex

  # Indicates the number of spaces that a single tab represents. Any value
  # provided is silently converted to a positive integer.
  #
  # *Default*::       <tt>8</tt>
  # <b>Used in</b>::  #expand, #unexpand,
  #                   #paragraphs
  attr_accessor :tabstop
  undef :tabstop=;
  def tabstop=(tabs) #:nodoc:
    @tabstop = tabs.to_i.abs
  end

  # Specifies the format style. Allowable values are:
  # * +LEFT_ALIGN+
  # * +RIGHT_ALIGN+
  # * +RIGHT_FILL+
  # * +JUSTIFY+
  #
  # *Default*::       <tt>Text::Format::LEFT_ALIGN</tt>
  # <b>Used in</b>::  #format, #paragraphs
  attr_accessor :format_style
  undef :format_style=;
  def format_style=(fs) #:nodoc:
    raise ArgumentError, "Invalid value provided for format_style." unless [LEFT_ALIGN, RIGHT_ALIGN, RIGHT_FILL, JUSTIFY].include?(fs)
    @format_style = fs
  end

  # Indicates that the format style is left alignment.
  #
  # *Default*::       +true+
  # <b>Used in</b>::  #format, #paragraphs
  def left_align?
    @format_style == LEFT_ALIGN
  end

  # Indicates that the format style is right alignment.
  #
  # *Default*::       +false+
  # <b>Used in</b>::  #format, #paragraphs
  def right_align?
    @format_style == RIGHT_ALIGN
  end

  # Indicates that the format style is right fill.
  #
  # *Default*::       +false+
  # <b>Used in</b>::  #format, #paragraphs
  def right_fill?
    @format_style == RIGHT_FILL
  end

  # Indicates that the format style is full justification.
  #
  # *Default*::       +false+
  # <b>Used in</b>::  #format, #paragraphs
  def justify?
    @format_style == JUSTIFY
  end

  # The formatting object itself can be used as a #hyphenator, where the
  # default implementation of #hyphenate_to implements the conditions
  # necessary to properly produce SPLIT_CONTINUATION.
  def hyphenate_to(word, size)
    if (size - 2) < 0
      [nil, word]
    else
      [word[0 .. (size - 2)] + "\\", word[(size - 1) .. -1]]
    end
  end

  # Splits the provided word so that it is in two parts, <tt>word[0 .. (size
  # - 1)]</tt> and <tt>word[size .. -1]</tt>.
  def split_word_to(word, size)
    [word[0 .. (size - 1)], word[size .. -1]]
  end

  # Formats text into a nice paragraph format. The text is separated into
  # words and then reassembled a word at a time using the settings of this
  # Format object.
  #
  # If +text+ is +nil+, then the value of #text will be worked on.
  def format_one_paragraph(text = nil)
    text ||= @text
    text = text[0] if text.kind_of?(Array)

    # Convert the provided paragraph to a list of words.
    words = text.split(SPACES_RE).reverse.reject { |ww| ww.nil? or ww.empty? }

    text = []

    # Find the maximum line width and the initial indent string. TODO
    # 20050114 - allow the left and right margins to be specified as
    # strings. If they are strings, then we need to use the sizes of the
    # strings. Also: allow the indent string to be set manually and indicate
    # whether the indent string will have a following space.
    max_line_width = @columns - @first_indent - @left_margin - @right_margin
    indent_str = ' ' * @first_indent

    first_line = true

    if words.empty?
      line        = []
      line_size   = 0
      extra_space = false
    else
      line        = [ words.pop ]
      line_size   = line[-1].size
      extra_space = __add_extra_space?(line[-1])
    end

    while next_word = words.pop
      next_word.strip! unless next_word.nil?
      new_line_size = (next_word.size + line_size) + 1

      if extra_space
        if (line[-1] !~ __sentence_end_re)
          extra_space = false
        end
      end

      # Increase the width of the new line if there's a sentence
      # terminator and we are applying extra_space.
      new_line_size += 1 if extra_space

      # Will the word fit onto the current line? If so, simply append it
      # to the end of the line.

      if new_line_size <= max_line_width
        if line.empty?
          line << next_word
        else
          if extra_space
            line << "  #{next_word}"
          else
            line << " #{next_word}"
          end
        end
      else
        # Forcibly wrap the line if nonbreaking spaces are turned on and
        # there is a condition where words must be wrapped. If we have
        # returned more than one word, readjust the word list.
        line, next_word = __wrap_line(line, next_word) if @nobreak
        if next_word.kind_of?(Array)
          if next_word.size > 1
            words.push(*(next_word.reverse))
            next_word = words.pop
          else
            next_word = next_word[0]
          end
          next_word.strip! unless next_word.nil?
        end

        # Check to see if the line needs to be hyphenated. If a word has a
        # hyphen in it (e.g., "fixed-width"), then we can ALWAYS wrap at
        # that hyphenation, even if #hard_margins is not turned on. More
        # elaborate forms of hyphenation will only be performed if
        # #hard_margins is turned on. If we have returned more than one
        # word, readjust the word list.
        line, new_line_size, next_word = __hyphenate(line, line_size, next_word, max_line_width)
        if next_word.kind_of?(Array)
          if next_word.size > 1
            words.push(*(next_word.reverse))
            next_word = words.pop
          else
            next_word = next_word[0]
          end
          next_word.strip! unless next_word.nil?
        end

        text << __make_line(line, indent_str, max_line_width, next_word.nil?) unless line.nil?

        if first_line
          first_line = false
          max_line_width = @columns - @body_indent - @left_margin - @right_margin
          indent_str = ' ' * @body_indent
        end

        if next_word.nil?
          line          = []
          new_line_size = 0
        else
          line          = [ next_word ]
          new_line_size = next_word.size
        end
      end

      line_size   = new_line_size
      extra_space = __add_extra_space?(next_word) unless next_word.nil?
    end

    loop do
      break if line.nil? or line.empty?
      line, line_size, ww = __hyphenate(line, line_size, ww, max_line_width)#if @hard_margins
      text << __make_line(line, indent_str, max_line_width, ww.nil?)
      line = ww
      ww = nil
    end

    if (@tag_paragraph and (not text.empty?))
      if @tag_cur.nil? or @tag_cur.empty?
        @tag_cur = @tag_text[0]
      end

      fchar = /(\S)/o.match(text[0])[1]
      white = text[0].index(fchar)

      unless @tag_cur.nil?
        if ((white - @left_margin - 1) > @tag_cur.size) then
          white = @tag_cur.size + @left_margin
          text[0].gsub!(/^ {#{white}}/, "#{' ' * @left_margin}#{@tag_cur}")
        else
          text.unshift("#{' ' * @left_margin}#{@tag_cur}\n")
        end
      end
    end

    text.join
  end
  alias_method :format, :format_one_paragraph

  # Considers each element of text (provided or internal) as a paragraph. If
  # #first_indent is the same as #body_indent, then paragraphs will be
  # separated by a single empty line in the result; otherwise, the
  # paragraphs will follow immediately after each other. Uses #format to do
  # the heavy lifting.
  #
  # If +to_wrap+ responds to #split, then it will be split into an array of
  # elements by calling #split with the value of +split_on+. The default
  # value of split_on is $/, or the default record separator, repeated twice
  # (e.g., /\n\n/).
  def paragraphs(to_wrap = nil, split_on = /(#{$/}){2}/o)
    to_wrap = @text if to_wrap.nil?
    if to_wrap.respond_to?(:split)
      to_wrap = to_wrap.split(split_on)
    else
      to_wrap = [to_wrap].flatten
    end

    if ((@first_indent == @body_indent) or @tag_paragraph) then
      p_end = NEWLINE
    else
      p_end = ''
    end

    cnt = 0
    ret = []
    to_wrap.each do |tw|
      @tag_cur = @tag_text[cnt] if @tag_paragraph
      @tag_cur = '' if @tag_cur.nil?
      line = format(tw)
      ret << (line + p_end) if (not line.nil?) and (line.size > 0)
      cnt += 1
    end

    ret[-1].chomp! unless ret.empty?
    ret.join
  end

  # Centers the text, preserving empty lines and tabs.
  def center(to_center = @text)
    to_center = [ to_center ].flatten

    tabs     = 0
    width    = @columns - @left_margin - @right_margin
    centered = []

    to_center.each do |tc|
      stripped   = tc.strip
      tabs       = stripped.count(TAB) || 0
      line_width = ((width - stripped.size - (tabs * @tabstop) + tabs) / 2)
      center_to  = (width - @left_margin - @right_margin) - line_width
      centered << (stripped.rjust(center_to) + NEWLINE)
    end

    centered.join
  end

  # Replaces all tab characters in the text with #tabstop spaces.
  def expand(to_expand = nil)
    to_expand = @text if to_expand.nil?

    tmp = ' ' * @tabstop
    changer = lambda do |text|
      res = text.split(NEWLINE_RE)
      res.collect! { |ln| ln.gsub!(/\t/o, tmp) }
      res.join(NEWLINE)
    end

    if to_expand.kind_of?(Array)
      to_expand.collect { |te| changer[te] }
    else
      changer[to_expand]
    end
  end

  # Replaces all occurrences of #tabstop consecutive spaces with a tab
  # character.
  def unexpand(to_unexpand = nil)
    to_unexpand = @text if to_unexpand.nil?

    tmp = / {#{@tabstop}}/
      changer = lambda do |text|
      res = text.split(NEWLINE_RE)
      res.collect! { |ln| ln.gsub!(tmp, TAB) }
      res.join(NEWLINE)
      end

    if to_unexpand.kind_of?(Array)
      to_unexpand.collect { |tu| changer[tu] }
    else
      changer[to_unexpand]
    end
  end

  # Create a Text::Format object. Accepts an optional hash of construction
  # options (this will be changed to named paramters in Ruby 2.0). After
  # the initial object is constructed (with either the provided or default
  # values), the object will be yielded (as +self+) to an optional block
  # for further construction and operation.
  def initialize(options = {}) #:yields self:
    @text                 = options.fetch(:text, [])
    @columns              = options.fetch(:columns, 72)
    @tabstop              = options.fetch(:tabstop, 8)
    @first_indent         = options.fetch(:first_indent, 4)
    @body_indent          = options.fetch(:body_indent, 0)
    @format_style         = options.fetch(:format_style, LEFT_ALIGN)
    @left_margin          = options.fetch(:left_margin, 0)
    @right_margin         = options.fetch(:right_margin, 0)
    @extra_space          = options.fetch(:extra_space, false)
    @tag_paragraph        = options.fetch(:tag_paragraph, false)
    @tag_text             = options.fetch(:tag_text, [])
    @abbreviations        = options.fetch(:abbreviations, [])
    @terminal_punctuation = options.fetch(:terminal_punctuation, "")
    @terminal_quotes      = options.fetch(:terminal_quotes, "")
    @nobreak              = options.fetch(:nobreak, false)
    @nobreak_regex        = options.fetch(:nobreak_regex, {})
    @hard_margins         = options.fetch(:hard_margins, false)
    @split_rules          = options.fetch(:split_rules, SPLIT_FIXED)
    @hyphenator           = options.fetch(:hyphenator, self)

    @hyphenator_arity     = @hyphenator.method(:hyphenate_to).arity
    @tag_cur              = ""
    @split_words          = []

    yield self if block_given?
  end
end

require 'text/format/internals'
