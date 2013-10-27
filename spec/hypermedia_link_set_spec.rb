require 'spec_helper'

describe Frenetic::HypermediaLinkSet do
  subject(:instance) { described_class.new links }

  describe '#initialize' do
    context 'with a single link' do
      let(:links) { { href:'foo' } }

      it 'should convert the argument to an array' do
        expect(subject.size).to eq 1
      end

      it 'should transform it into HypermediaLink' do
        expect(subject.first).to be_an_instance_of Frenetic::HypermediaLink
      end
    end
  end

  describe '#href' do
    subject { super().href tmpl_data }

    context 'without template data' do
      let(:tmpl_data) {}

      context 'with a single link in the set' do
        let(:link_a) do
          Frenetic::HypermediaLink.new href:'/foo/bar'
        end

        let(:links) { [link_a] }

        it 'should return the HREF of the first link' do
          link_a.should_receive( :href ).and_call_original

          expect(subject).to eq '/foo/bar'
        end
      end

      context 'with multiple links in the set' do
        let(:links) do
          [
            { href:'/foo/bar' },
            { href:'/baz/qux' }
          ]
        end

        it 'should return the first link in the set' do
          expect(subject).to eq '/foo/bar'
        end
      end
    end

    context 'with template data' do
      let(:tmpl_data) { { id:1 } }

      let(:link_a) do
        Frenetic::HypermediaLink.new href:'/foo/{id}', templated:true
      end

      let(:links) { [link_a] }

      it 'should find most relevant link' do
        instance.should_receive :find_relevant_link

        subject
      end

      it 'should pass along the template data' do
        link_a.should_receive( :href )
          .with( tmpl_data )
          .and_call_original

        subject
      end
    end
  end

  describe '#find_relevant_link' do
    let(:tmpl_data) { { id:1 } }

    subject { super().find_relevant_link tmpl_data }

    context 'with a single, matching link' do
      let(:links) do
        [
          { href:'/foo/{id}', templated:true }
        ]
      end

      it 'should return the matching link' do
        expect(subject).to be_an_instance_of Frenetic::HypermediaLink
      end
    end

    context 'with multiple matching links' do
      let(:link_a) do
        Frenetic::HypermediaLink.new( href:'/foo/{id}', templated:true )
      end

      let(:links) do
        [
          link_a,
          { href:'/bar/{id}', templated:true }
        ]
      end

      it 'should return the first matching link' do
        expect(subject).to eq link_a
      end
    end

    context 'with no matching links' do
      let(:links) do
        [
          { href:'/foo/{fname}', templated:true },
          { href:'/foo/{lname}', templated:true }
        ]
      end

      it 'should raise an error' do
        expect{ subject }.to raise_error Frenetic::HypermediaError
      end
    end
  end

  describe '#[]' do
    subject { super()[rel] }

    let(:link_b) do
      Frenetic::HypermediaLink.new( href:'/bar', rel:'bar' )
    end

    let(:links) do
      [
        { href:'/foo', rel:'foo' },
        link_b
      ]
    end

    context 'for a relation that exists' do
      let(:rel) { :bar }

      it { should eq link_b }
    end

    context 'for a relation that does not exist' do
      let(:rel) { :baz }

      it { should be_nil }
    end
  end
end