require 'spec_helper'

describe TeamDecorator do
  describe '.image' do
    context 'with explicit image' do
      subject { build(:team, image: 'xyz.jpg').decorate }
      it 'returns the image' do
        subject.image.should match(subject.object.image)
      end
    end
    context 'without explicit image' do
      context 'with no parent team image' do
        subject { build(:team, image: nil, parent_team: nil).decorate }
        xit 'returns the avatar service image' do
          subject.image.should match("/service/avatar/")
        end
      end
      context 'with parent team image' do
        let(:parent_team) { build(:team, image: 'parent.jpg', parent_team: nil) }
        subject { build(:team, image: nil, parent_team: parent_team).decorate }
        it 'returns the parent team image' do
          subject.image.should match parent_team.image
        end
      end
    end
  end
  describe '.description' do
    context 'with blank description' do
      subject { build(:team, description: nil).decorate }
      it { subject.description.should match subject.send(:generated_description) }
    end
    context 'with explicit description' do
      subject { build(:team, description: 'xyz').decorate }
      it { subject.description.should eq subject.object.description }
    end
  end
  describe '.name' do
    context 'when independent' do
      subject { build(:team, name: TeamDecorator::INDEPENDENT).decorate }
      it { subject.name.should match TeamDecorator::INDEPENDENT }
    end
    context 'with not independent' do
      subject { build(:team, name: 'xyz').decorate }
      it { subject.name.should eq 'xyz' }
    end
  end
end
