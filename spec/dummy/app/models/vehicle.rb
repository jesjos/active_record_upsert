class Vehicle < ApplicationRecord
  upsert_keys [:make, :name]

  before_save :before_s
  after_save :after_s
  before_create :before_c
  after_create :after_c
  after_commit :after_com

  def before_s
  end

  def after_s
  end

  def before_c
  end

  def after_c
  end

  def after_com
  end
end
