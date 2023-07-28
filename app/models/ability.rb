class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)

    if user.admin?
      can :manage, :all
    else
      can :read, [User, Room, RoomDailyPrice]
      can :create, Reservation
      can :manage, Reservation, user_id: user.id
    end
  end
end
