# frozen_string_literal: true

RSpec.describe NullByteFinder do
  subject(:null_byte_finder) { NullByteFinder.new(object) }

  describe 'has_null_byte?' do
    subject(:has_null_byte?) { null_byte_finder.has_null_byte? }

    context 'when the object is nil' do
      let(:object) { nil }

      it 'returns false' do
        expect(has_null_byte?).to eq(false)
      end
    end

    context 'when the object is a string' do
      context 'when the string does not include a null byte' do
        let(:object) { 'Expelliarmus!' }

        it 'returns false' do
          expect(has_null_byte?).to eq(false)
        end
      end

      context 'when the string includes a null byte' do
        let(:object) { "so hacked \u0000" }

        it 'returns true' do
          expect(has_null_byte?).to eq(true)
        end
      end
    end

    context 'when the object is an array' do
      context 'when none of the array elements includes a null byte' do
        let(:object) { ['Expelliarmus!', 'Accio!'] }

        it 'returns false' do
          expect(has_null_byte?).to eq(false)
        end
      end

      context 'when at least one of the array elements includes a null byte' do
        let(:object) { ['so', "hacked \u0000"] }

        it 'returns true' do
          expect(has_null_byte?).to eq(true)
        end
      end
    end

    context 'when the object is a hash' do
      context 'when none of the hash keys or values includes a null byte' do
        let(:object) { { 'Expelliarmus!' => 'Accio!' } }

        it 'returns false' do
          expect(has_null_byte?).to eq(false)
        end
      end

      context 'when one of the hash keys includes a null byte' do
        let(:object) { { "Expelliarmus!\u0000" => 'Accio!' } }

        it 'returns true' do
          expect(has_null_byte?).to eq(true)
        end
      end

      context 'when one of the hash values includes a null byte' do
        let(:object) { { 'Expelliarmus!' => "\u0000Accio!" } }

        it 'returns true' do
          expect(has_null_byte?).to eq(true)
        end
      end
    end

    context 'when the object is a symbol (or any other unsupported object type)' do
      let(:object) { :symbols_are_not_supported }

      it 'raises an error' do
        expect { has_null_byte? }.to raise_error(
          RuntimeError,
          'Do not know how to check for null bytes in object: :symbols_are_not_supported.',
        )
      end
    end
  end
end
