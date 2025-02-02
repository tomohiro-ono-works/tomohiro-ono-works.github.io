document.addEventListener("DOMContentLoaded", () => {
  const fileInput = document.getElementById("configFileInput");
  // const importButton = document.getElementById("importConfigButton");

  fileInput.addEventListener("change", () => {
    if (fileInput.files.length === 0) {
      alert("設定ファイルを選択してください。");
      return;
    }

    const file = fileInput.files[0];
    const reader = new FileReader();

    reader.onload = (event) => {
      try {
        const config = JSON.parse(event.target.result);
        localStorage.setItem("tableauConfig", JSON.stringify(config)); // 設定を保存
        renderDashboards(config);
      } catch (error) {
        console.error("設定ファイルの読み込みに失敗しました:", error);
        alert("無効なJSONファイルです。");
      }
    };

    reader.readAsText(file);
  });
});

/**
 * ダッシュボードを動的に生成する関数
 */
function renderDashboards(config) {
  const container = document.getElementById("dashboardContainer");
  container.innerHTML = ""; // 既存のダッシュボードをクリア

  config.testCases.forEach((testCase, index) => {
    createDashboard(container, testCase, index);
  });
};


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
  pdfButton.textContent = "Step2.PDFダウンロード";
  pdfButton.classList.add("pdf-button");
  pdfButton.setAttribute("data-index", index);
  titleContainer.appendChild(pdfButton);


  wrapper.appendChild(titleContainer);

  const tableauViz = document.createElement("tableau-viz");
  tableauViz.setAttribute("src", testCase.dashboardUrl);
  tableauViz.setAttribute("toolbar", "bottom");
  tableauViz.setAttribute("hide-tabs", "");
  tableauViz.setAttribute("id", `tableau-viz-${index}`); // IDを付与
  // tableauViz.style.width='800px';
  // tableauViz.style.height='827px';
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
};
