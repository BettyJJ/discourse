import Component from "@glimmer/component";
import { action } from "@ember/object";
import DModal from "discourse/components/d-modal";
import DButton from "discourse/components/d-button";
import PreferenceCheckbox from "discourse/components/preference-checkbox";
import I18n from "I18n";
import { tracked } from "@glimmer/tracking";

const REPLIES_SUBSET = "replies";
const TOPICS_SUBSET = "topics";

export default class DismissNew extends Component {
  <template>
    <DModal
      @closeModal={{@closeModal}}
      @title={{this.modalTitle}}
      @inline={{@inline}}
    >
      <:body>
        <p>
          {{#if this.showDismissNewTopics}}
            <PreferenceCheckbox
              @labelKey={{this.dismissNewTopicsLabel}}
              @labelCount={{this.countNewTopics}}
              @checked={{this.dismissTopics}}
              @class="dismiss-topics"
            />
          {{/if}}
          {{#if this.showDismissNewReplies}}
            <PreferenceCheckbox
              @labelKey={{this.dismissNewRepliesLabel}}
              @labelCount={{this.countNewReplies}}
              @checked={{this.dismissPosts}}
              @class="dismiss-posts"
            />
          {{/if}}
          <PreferenceCheckbox
            @labelKey="topics.bulk.dismiss_new_modal.untrack"
            @checked={{this.untrack}}
            @class="untrack"
          />
        </p>
      </:body>
      <:footer>
        <DButton
          id="dismiss-read-confirm"
          @action={{this.dismissed}}
          @icon="check"
          @label="topics.bulk.dismiss"
          class="btn-primary"
        />
      </:footer>
    </DModal>
  </template>

  @tracked untrack = false;
  @tracked dismissTopics = true;
  @tracked dismissPosts = true;

  constructor() {
    super(...arguments);

    if (this.args.model.subset === "replies") {
      this.dismissTopics = false;
    }
    if (this.args.model.subset === "topics") {
      this.dismissPosts = false;
    }
  }

  get partialDismiss() {
    return (this.selectedTopics?.length || 0) !== 0;
  }

  get dismissNewTopicsLabel() {
    return (
      "topics.bulk.dismiss_new_modal.topics" +
      (this.partialDismiss ? "_with_count" : "")
    );
  }

  get dismissNewRepliesLabel() {
    return (
      "topics.bulk.dismiss_new_modal.replies" +
      (this.partialDismiss ? "_with_count" : "")
    );
  }

  get showDismissNewTopics() {
    if (this.partialDismiss) {
      return this.countNewTopics > 0;
    }

    return this.subset === TOPICS_SUBSET || !this.subset;
  }

  get showDismissNewReplies() {
    if (this.partialDismiss) {
      return this.countNewReplies > 0;
    }

    return this.subset === REPLIES_SUBSET || !this.subset;
  }

  get countNewTopics() {
    const topics = this.selectedTopics;
    if (!topics?.length) {
      return 0;
    }

    return topics.filter((topic) => !topic.unread_posts).length;
  }

  get countNewReplies() {
    const topics = this.selectedTopics;
    if (!topics?.length) {
      return 0;
    }
    return topics.filter((topic) => topic.unread_posts).length;
  }

  get subset() {
    return this.args.model.subset;
  }

  get selectedTopics() {
    return this.args.model.selectedTopics;
  }

  get modalTitle() {
    return I18n.t("topics.bulk.dismiss_new_modal.title");
  }

  @action
  dismissed() {
    this.args.model.dismissCallback({
      dismissTopics: this.dismissTopics,
      dismissPosts: this.dismissPosts,
      untrack: this.untrack,
    });

    this.args.closeModal();
  }
}
