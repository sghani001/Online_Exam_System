module PersonaTracking
  extend ActiveSupport::Concern

  private

  def persona_track(action, metadata = {})
    return unless defined?(Persona) || defined?(Persona::Event)

    begin
      if defined?(Persona::Event)
        Persona::Event.create(
          trackable_type: current_user.class.name,
          trackable_id: current_user.id,
          action: action.to_s,
          metadata: metadata
        )
      elsif defined?(Persona)
        # Fallback: attempt generic API if available
        Persona.track(current_user, action: action.to_s, metadata: metadata) if current_user
      end
    rescue => e
      Rails.logger.warn "Persona tracking failed: "+ e.message
    end
  end
end
