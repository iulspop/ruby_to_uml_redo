require_relative '../lib/ruby_to_uml'

class TestUMLInfoGeneratorCapturesClassInfoCorrectly < Minitest::Test
  def test_classes_returns_name_of_every_class_in_files
    # Setup
    input = <<~MSG.chomp
      class Stack
      end

      class LinkedList

        class EmptyLinkedList

        end
      end
    MSG

    # Execute
    uml_info = UMLInfoGenerator.process_code(input)

    # Assert
    expected = %w[Stack LinkedList EmptyLinkedList]
    assert_equal(expected, uml_info.class_names)
  end

  def test_classes_contain_instance_methods_and_identify_type_correctly
      # Setup
      input = <<~MSG.chomp
        class LinkedList
          def conj(item); end
          def empty?; end
          protected
          def ==(other); end
          private
          def traverse(index); end
        end
      MSG
  
      # Execute
      uml_info = UMLInfoGenerator.process_code(input)
  
      # Assert
      instance_methods = <<~MSG.chomp
        public conj(item)
        public empty?()
        protected ==(other)
        private traverse(index)
      MSG
      expected = [instance_methods]
      assert_equal(expected, uml_info.instance_methods)
  end

  def test_classes_contain_singleton_methods_and_ignore_public_private_protected_type_and_ignore_instance_methods
      # Setup
      input = <<~MSG.chomp
        class LinkedList
          def self.conj(item); end
          def empty?; end
          protected
          def self.==(other); end
          private
          def self.traverse(index); end
        end
      MSG
  
      # Execute
      uml_info = UMLInfoGenerator.process_code(input)
  
      # Assert
      singleton_methods = <<~MSG.chomp
        self.conj(item)
        self.==(other)
        self.traverse(index)
      MSG
      expected = [singleton_methods]
      assert_equal(expected, uml_info.singleton_methods)
  end

  def test_classes_contain_instance_methods_even_when_only_one_method_defined
    # Setup
    input = <<~MSG.chomp
      class Turtle
        def yellow(iron)

        end
      end
    MSG

    # Execute
    uml_info = UMLInfoGenerator.process_code(input)

    # Assert
    expected = ["public yellow(iron)"]
    assert_equal(expected, uml_info.instance_methods)
  end

  def test_classes_contain_singleton_methods_even_when_only_one_method_defined
    # Setup
    input = <<~MSG.chomp
    class Turtle
      def self.yellow(iron)

      end
    end
    MSG

    # Execute
    uml_info = UMLInfoGenerator.process_code(input)

    # Assert
    expected = ["self.yellow(iron)"]
    assert_equal(expected, uml_info.singleton_methods)
  end
end

class TestUMLInfoGeneratorCapturesRelationshipsCorrectly < Minitest::Test
  def setup
    file = "test/fixtures/linked_list.rb"
    @uml_info = UMLInfoGenerator.process_file(file)
  end

  def test_relationships_includes_any_inheritence_relationships
    inherits_relationship = "EmptyLinkedList inherits LinkedList"
    assert_includes(@uml_info.relationships, inherits_relationship)
  end

  def test_relationships_includes_any_include_relationships
    includes_relationship = "LinkedList includes Enumerable"
    assert_includes(@uml_info.relationships, includes_relationship)
  end

  def test_relationships_includes_any_extend_relationships
    extends_relationship = "LinkedList extends Utils"
    assert_includes(@uml_info.relationships, extends_relationship)
  end

  def test_relationships_includes_any_prepend_relationships
    prepends_relationship = "Stack prepends Extras"
    assert_includes(@uml_info.relationships, prepends_relationship)
  end
end