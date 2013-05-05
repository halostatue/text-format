# -*- ruby encoding: utf-8 -*-

module Text::Format::Internals # :nodoc:
  private

  # This method returns the regular expression used to detect the end of a
  # sentence under the definition of TERMINAL_PUNCTUATION and
  # TERMINAL_QUOTES and the current definitions of #terminal_punctuation and
  # #terminal_quotes.
  def __sentence_end_re
    %r{
      [#{Text::Format::TERMINAL_PUNCTUATION}#{self.terminal_punctuation}]
      [#{Text::Format::TERMINAL_QUOTES}#{self.terminal_quotes}]?
      $
    }x
  end

  # Return +true+ if the word may have an extra space added after it. This
  # will only be the case if #extra_space is +true+ and the word is not an
  # abbreviation.
  def __add_extra_space?(word)
    return false unless @extra_space
    word = word.gsub(/\.$/o, '') unless word.nil?
    return false if Text::Format::ABBREV.include?(word)
    return false if @abbreviations.include?(word)
    true
  end

  def __make_line(line, indent, width, last = false)
    line_size = line.inject(0) { |ls, el| ls + el.size }
    lmargin = " " * @left_margin
    fill = " " * (width - line_size) if right_fill? and (line_size <= width)

    unless last
      if justify? and (line.size > 1)
        spaces      = width - line_size
        word_spaces = spaces / (line.size / 2)
        spaces      = spaces % (line.size / 2) if word_spaces > 0
        line.reverse.each do |word|
          next if (word =~ /^\S/o)

          word.sub!(/^/o, " " * word_spaces)

          next unless (spaces > 0)

          word.sub!(/^/o, " ")
          spaces -= 1
        end
      end
    end

    line = "#{lmargin}#{indent}#{line.join('')}#{fill}\n" unless line.empty?

    if right_align? and (not line.nil?)
      line.sub(/^/o, " " * (@columns - @right_margin - (line.size - 1)))
    else
      line
    end
  end

  def __hyphenate(line, line_size, next_word, width)
    return [ line, line_size, next_word ] if line.nil? or line.empty?
    rline = line.dup
    rsize = line_size

    rnext = []
    rnext << next_word.dup unless next_word.nil?

    loop do
      break if rnext.nil? or rline.nil?

      if rsize == width
        break
      elsif rsize > width
        word = rline.pop
        size = width - rsize + word.size

        if (size < 1)
          rnext.unshift word
          next
        end

        first = rest = nil

        # TODO: Add the check to see if the word contains a hyphen to
        # split on automatically.
        # Does the word already have a hyphen in it? If so, try to use
        # that to split the word.
        #       if word.index('-') < size
        #         first = word[0 ... word.index("-")]
        #         rest  = word[word.index("-") .. -1]
        #       end

        if @hard_margins
          if first.nil? and (@split_rules & Text::Format::SPLIT_HYPHENATION) == Text::Format::SPLIT_HYPHENATION
            if @hyphenator_arity == 2
              first, rest = @hyphenator.hyphenate_to(word, size)
            else
              first, rest = @hyphenator.hyphenate_to(word, size, self)
            end
          end

          if first.nil? and (@split_rules & Text::Format::SPLIT_CONTINUATION) == Text::Format::SPLIT_CONTINUATION
            first, rest = self.hyphenate_to(word, size)
          end

          if first.nil?
            if (@split_rules & Text::Format::SPLIT_FIXED) == Text::Format::SPLIT_FIXED
              first, rest = split_word_to(word, size)
            elsif (not rest.nil? and (rest.size > size))
              first, rest = split_word_to(word, size)
            end
          end
        else
          first = word if first.nil?
        end

        if first.nil?
          rest = word
        else
          rsize = rsize - word.size + first.size
          if rline.empty?
            rline << first
          else
            rsize += 1
            rline << " #{first}"
          end
          @split_words << Text::Format::SplitWord.new(word, first, rest)
        end
        rnext.unshift rest unless rest.nil?
        break
      else
        break if rnext.empty?
        word = rnext.shift.dup
        size = width - rsize - 1

        if (size <= 0)
          rnext.unshift word
          break
        end

        first = rest = nil

        # TODO: Add the check to see if the word contains a hyphen to
        # split on automatically.
        # Does the word already have a hyphen in it? If so, try to use
        # that to split the word.
        #       if word.index('-') < size
        #         first = word[0 ... word.index("-")]
        #         rest  = word[word.index("-") .. -1]
        #       end

        if @hard_margins
          if (@split_rules & Text::Format::SPLIT_HYPHENATION) == Text::Format::SPLIT_HYPHENATION
            if @hyphenator_arity == 2
              first, rest = @hyphenator.hyphenate_to(word, size)
            else
              first, rest = @hyphenator.hyphenate_to(word, size, self)
            end
          end

          if first.nil? and (@split_rules & Text::Format::SPLIT_CONTINUATION) == Text::Format::SPLIT_CONTINUATION
            first, rest = self.hyphenate_to(word, size)
          end

          if first.nil?
            if (@split_rules & Text::Format::SPLIT_FIXED) == Text::Format::SPLIT_FIXED
              first, rest = split_word_to(word, size)
            elsif (not rest.nil? and (rest.size > width))
              first, rest = split_word_to(word, size)
            end
          end
        else
          first = word if first.nil?
        end

        # The word was successfully split. Does it fit?
        unless first.nil?
          if (rsize + first.size) < width
            @split_words << Text::Format::SplitWord.new(word, first, rest)

            rsize += first.size + 1
            rline << " #{first}"
          else
            rest = word
          end
        else
          rest = word unless rest.nil?
        end

        rnext.unshift rest
        break
      end
    end
    [ rline, rsize, rnext ]
  end

  # The line must be broken. Typically, this is done by moving the last word
  # on the current line to the next line. However, it may be possible that
  # certain combinations of words may not be broken (see #nobreak_regex for
  # more information). Therefore, it may be necessary to move multiple words
  # from the current line to the next line. This function does this.
  def __wrap_line(line, next_word)
    no_break = false

    word_index  = line.size - 1

    @nobreak_regex.each_pair do |first, second|
      if line[word_index] =~ first and next_word =~ second
        no_break = true
      end
    end

    # If the last word and the next word aren't to be broken, and the line
    # has more than one word in it, then we need to go back by words to
    # ensure that we break as allowed.
    if no_break and word_index.nonzero?
      word_index -= 1

      while word_index.nonzero?
        no_break = false
        @nobreak_regex.each_pair { |first, second|
          if line[word_index] =~ first and line[word_index + 1] =~ second
            no_break = true
          end
        }

        break unless no_break
        word_index -= 1
      end

      if word_index.nonzero?
        words = line.slice!(word_index .. -1)
        words << next_word
      end
    end

    [line, words]
  end
end

class Text::Format
  include Text::Format::Internals
end
