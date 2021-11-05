<script>
  import { fade } from 'svelte/transition';

  export let showModal, closeModal;
</script>

{#if showModal}
  <div class="modal" in:fade out:fade>
    <a href="https://youtu.be/dU5a4PRSF14" target="_blank">Click here</a> to see a video tutorial of this website.
    <button on:click={closeModal}>Close message.</button>
  </div>
{/if}

<style>
  .modal {
    position: absolute;
    top: 15px;
    left: 50%;
    transform: translateX(-50%);
    background: white;
    padding: 3px 8px;
    font-size: 18px;
    border-radius: 3px;
    border: 1px solid #ddd;
    z-index: 100;
  }

  button {
    text-decoration: underline;
  }
</style>