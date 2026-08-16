(() => {
  const mobileQuery = window.matchMedia('(max-width: 600px)');
  const cards = [...document.querySelectorAll('.form-card')];
  let initialized = false;

  function setOpen(card, open) {
    card.classList.toggle('is-open', open);
    card.querySelector('.card-heading').setAttribute('aria-expanded', String(open));
  }

  function applyMobileAccordion() {
    if (!mobileQuery.matches) {
      cards.forEach((card) => card.classList.remove('is-collapsible'));
      return;
    }
    cards.forEach((card, index) => {
      const heading = card.querySelector('.card-heading');
      card.classList.add('is-collapsible');
      heading.setAttribute('role', 'button');
      heading.setAttribute('tabindex', '0');
      if (!initialized) setOpen(card, index === 0);
    });
    initialized = true;
  }

  cards.forEach((card) => {
    const heading = card.querySelector('.card-heading');
    const toggle = () => {
      if (!mobileQuery.matches) return;
      setOpen(card, !card.classList.contains('is-open'));
    };
    heading.addEventListener('click', toggle);
    heading.addEventListener('keydown', (event) => {
      if (event.key === 'Enter' || event.key === ' ') { event.preventDefault(); toggle(); }
    });
  });
  mobileQuery.addEventListener('change', applyMobileAccordion);
  applyMobileAccordion();
})();
