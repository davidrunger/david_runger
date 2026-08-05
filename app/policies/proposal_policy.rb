class ProposalPolicy < ApplicationPolicy
  def create?
    user.spouse.nil?
  end

  def confirm?
    intended_recipient?
  end

  def accept?
    intended_recipient?
  end

  private

  def intended_recipient?
    record.proposee_email.casecmp?(user.email)
  end
end
