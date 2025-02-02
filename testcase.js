/**
 * 各テストケースごとにダッシュボード・ボタンを作成
 */
function createDashboard(container, testCase, index) {
  const wrapper = document.createElement("div");
  wrapper.classList.add("dashboard-wrapper");

  // タイトルとボタンのコンテナ
  const titleContainer = document.createElement("div");
  titleContainer.classList.add("title-container");

  const title = document.createElement("h2");
  title.textContent = testCase.name;
  titleContainer.appendChild(title);

  // PDFダウンロードボタン
  const pdfButton = document.createElement("button");
  pdfButton.textContent = "PDFダウンロード";
  pdfButton.classList.add("pdf-button");
  pdfButton.setAttribute("data-index", index);
  titleContainer.appendChild(pdfButton);


  wrapper.appendChild(titleContainer);

  const tableauViz = document.createElement("tableau-viz");
  tableauViz.setAttribute("src", testCase.dashboardUrl);
  tableauViz.setAttribute("toolbar", "bottom");
  tableauViz.setAttribute("hide-tabs", "");
  tableauViz.setAttribute("id", `tableau-viz-${index}`); // IDを付与
  const config = JSON.parse(localStorage.getItem("tableauConfig"));
  const filters = config.testCases[index].filterPattern
  filters.forEach(filter => {
    console.log(`フィルター適用: ${filter.field} = ${filter.value}`);
    const vizFilter = document.createElement("viz-filter");
    vizFilter.setAttribute("field", filter.field);
    vizFilter.setAttribute("value", Array.isArray(filter.value) ? filter.value.join(",") : filter.value);
    tableauViz.appendChild(vizFilter);
  });
  wrapper.appendChild(tableauViz);
  container.appendChild(wrapper);
}
