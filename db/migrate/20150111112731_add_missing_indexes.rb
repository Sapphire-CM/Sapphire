# $ consistency_fail                                                                                                       [1]

# There are calls to validates_uniqueness_of that aren't backed by unique indexes.
# --------------------------------------------------------------------------------
# Model                 Table Columns
# --------------------------------------------------------------------------------
# Account               accounts (matriculation_number)
# Course                courses (title)
# EmailAddress          email_addresses (email)
# Exercise              exercises (title, term_id)
# RatingGroup           rating_groups (title, exercise_id)
# ResultPublication     result_publications (exercise_id, tutorial_group_id)
# SubmissionEvaluation  submission_evaluations (submission_id)
# Term                  terms (title, course_id)
# TermRegistration      term_registrations (account_id, term_id)
# TutorialGroup         tutorial_groups (title, term_id)
# --------------------------------------------------------------------------------


# There are calls to has_one that aren't backed by unique indexes.
# --------------------------------------------------------------------------------
# Model       Table Columns
# --------------------------------------------------------------------------------
# Submission  submission_evaluations (submission_id)
# Term        lecturer_registrations (term_id)
# --------------------------------------------------------------------------------

# Hooray! All calls to has_one_with_polymorphic are correctly backed by a unique index.

#######################################################################################

# this requires that all Account#matriculation_number values are either valid or NULL.
# run: Account.where(matriculation_number: '').each { |a| a.update! matriculation_number: nil }

#######################################################################################



class AddMissingIndexes < ActiveRecord::Migration
  def change
    remove_index :submission_evaluations, column: :submission_id
    remove_index :lecturer_registrations, column: :term_id

    add_index :accounts,                :matriculation_number,               unique: true
    add_index :courses,                 :title,                              unique: true
    add_index :email_addresses,         :email,                              unique: true
    add_index :exercises,               [:title, :term_id],                  unique: true
    add_index :rating_groups,           [:title, :exercise_id],              unique: true
    add_index :result_publications,     [:exercise_id, :tutorial_group_id],  unique: true
    add_index :submission_evaluations,  :submission_id,                      unique: true
    add_index :terms,                   [:title, :course_id],                unique: true
    add_index :term_registrations,      [:account_id, :term_id],             unique: true
    add_index :tutorial_groups,         [:title, :term_id],                  unique: true
    add_index :lecturer_registrations,  :term_id,                            unique: true
  end
end
