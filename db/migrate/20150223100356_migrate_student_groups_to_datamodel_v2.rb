class MigrateStudentGroupsToDatamodelV2 < ActiveRecord::Migration
  def up
    # removing solitary student groups
    say_with_time("removing solitary groups") do
      StudentGroup.unscoped.where(solitary: true).delete_all
    end
    remove_column :student_groups, :solitary, :boolean

    # add student group to submissions
    change_table :submissions do |t|
      t.belongs_to :student_group, index: true
    end

    say_with_time("add existing student_groups to submissions") do
      StudentGroup.unscoped.each do |student_group|
        active_student_group = if student_group.active?
          student_group
        else
          StudentGroup.unscoped.find_by!(tutorial_group: student_group.tutorial_group, title: student_group.title, active: true)
        end

        student_group_registration_ids = StudentGroupRegistration.unscoped.where(student_group_id: student_group.id).pluck(&:id)

        Submission.where(student_group_registration_id: student_group_registration_ids).update_all(student_group_id: active_student_group.id)
      end
    end


    # add student group to term_registrations
    change_table :term_registrations do |t|
      t.belongs_to :student_group, index: true
    end


    say_with_time("add active student groups to term_registrations") do
      StudentGroup.unscoped.where(active: true).each do |student_group|
        account_ids = StudentRegistration.unscoped.where(student_group_id: student_group.id).pluck(&:account_id)
        TermRegistration.unscoped.where(account_id: account_ids, tutorial_group: student_group.tutorial_group).update_all(student_group_id: student_group.id)
      end
    end

    say_with_time("remove inactive student groups") do
      StudentGroup.unscoped.where(active: false).delete_all
    end
    remove_column :student_groups, :active, :boolean

    # no more student group registrations needed
    drop_table :student_group_registrations
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
