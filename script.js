document.addEventListener('DOMContentLoaded', () => {
    const addButtons = document.querySelectorAll('.add-button');
    const removeButtons = document.querySelectorAll('.remove-button');
    const sidebarContent = document.getElementById('sidebar-content');

    addButtons.forEach(button => {
        button.addEventListener('click', event => {
            const product = event.target.closest('.product');
            const productId = product.getAttribute('data-product-id');
            const productName = product.getAttribute('data-product-name');
            const productPrice = product.getAttribute('data-product-price');

            const sidebarItem = document.createElement('div');
            sidebarItem.classList.add('sidebar-item');
            sidebarItem.setAttribute('data-product-id', productId);
            sidebarItem.innerHTML = `
                <h3>${productName}</h3>
                <p>${productPrice}</p>
            `;

            sidebarContent.appendChild(sidebarItem);
        });
    });

    removeButtons.forEach(button => {
        button.addEventListener('click', event => {
            const product = event.target.closest('.product');
            const productId = product.getAttribute('data-product-id');

            const sidebarItem = sidebarContent.querySelector(`.sidebar-item[data-product-id="${productId}"]`);
            if (sidebarItem) {
                sidebarContent.removeChild(sidebarItem);
            }
        });
    });
});
