module RedmineMessenger
  module Patches
    module ContactPatch
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
          after_create_commit :send_messenger_create
          after_update_commit :send_messenger_update
        end
      end

      module InstanceMethods
        def send_messenger_create
          return unless Messenger.setting_for_project(project, :post_contact)
          return if is_private? && !Messenger.setting_for_project(project, :post_private_contacts)

          set_language_if_valid Setting.default_language

          channels = Messenger.channels_for_project project
          url = Messenger.url_for_project project

          return unless channels.present? && url

          Messenger.speak(l(:label_messenger_contact_created,
                            project_url: "<#{Messenger.object_url project}|#{Messenger.markup_format(project)}>",
                            url: "<#{Messenger.object_url self}|#{name}>",
                            user: User.current),
                          channels, url, project: project)
        end

        def send_messenger_update
          return unless Messenger.setting_for_project(project, :post_contact_updates)
          return if is_private? && !Messenger.setting_for_project(project, :post_private_contacts)

          set_language_if_valid Setting.default_language

          channels = Messenger.channels_for_project project
          url = Messenger.url_for_project project

          return unless channels.present? && url

          Messenger.speak(l(:label_messenger_contact_updated,
                            project_url: "<#{Messenger.object_url project}|#{Messenger.markup_format(project)}>",
                            url: "<#{Messenger.object_url self}|#{name}>",
                            user: User.current),
                          channels, url, project: project)
        end
      end
    end
  end
end
