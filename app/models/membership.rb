class Membership < ActiveRecord::Base
  belongs_to :user
  belongs_to :space

protected 
  # gets the IDs for given space (or active space)
  # and user (or active user)
  def self.extract_space_and_user_ids(space=nil, user=nil)
    space ||= Space.active
    user  ||= User.active
    
    # we need both the space and the user
    return nil if space.nil? || user.nil?
   
    # get the IDs for space and user
    # (unless they are integers already)
    [space, user].map { |e| Integer === e ? e : e.id }
  end

public
  # finds membership association for given space and user
  def self.find_membership(space=nil, user=nil)
    space_id, user_id = extract_space_and_user_ids(space, user)
    return nil if space_id.nil?
    
    self.find(:first, :conditions => ['space_id = ? AND user_id = ?', space_id, user_id])
  end
  
  # finds the role for the given space and user
  def self.role(space=nil, user=nil)
    result = find_membership(space, user)
    result ? result.role.to_i : nil
  end
end