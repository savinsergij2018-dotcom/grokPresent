const UI = {
    settings: {
        theme: 'dark',
        accent: '#00ccff',
        activeTab: 'main'
    },

    init() {
        this.injectStyles();
        this.createContainer();
        this.render();
    },

    injectStyles() {
        const style = document.createElement('style');
        style.innerHTML = `
            :root {
                --bg-main: rgba(15, 15, 20, 0.95);
                --bg-card: rgba(25, 25, 35, 0.7);
                --accent: ${this.settings.accent};
                --text: #ffffff;
                --text-dim: #a0a0b0;
                --shadow: 0 10px 30px rgba(0, 0, 0, 0.5);
                --glass: blur(12px) saturate(180%);
            }

            .ui-overlay {
                position: fixed;
                top: 50%;
                left: 50%;
                transform: translate(-50%, -50%);
                width: 600px;
                height: 400px;
                background: var(--bg-main);
                backdrop-filter: var(--glass);
                -webkit-backdrop-filter: var(--glass);
                border: 1px solid rgba(255, 255, 255, 0.1);
                border-radius: 12px;
                display: flex;
                flex-direction: column;
                color: var(--text);
                font-family: 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
                box-shadow: var(--shadow);
                z-index: 999999;
                overflow: hidden;
            }

            .ui-header {
                padding: 20px;
                background: linear-gradient(90deg, rgba(0, 204, 255, 0.1), transparent);
                border-bottom: 1px solid rgba(255, 255, 255, 0.05);
                display: flex;
                justify-content: space-between;
                align-items: center;
            }

            .ui-title {
                font-size: 18px;
                font-weight: 700;
                letter-spacing: 1px;
                text-transform: uppercase;
                color: var(--accent);
            }

            .ui-body {
                display: flex;
                flex: 1;
                overflow: hidden;
            }

            .ui-sidebar {
                width: 160px;
                border-right: 1px solid rgba(255, 255, 255, 0.05);
                padding: 10px;
                background: rgba(0, 0, 0, 0.2);
            }

            .ui-nav-item {
                padding: 12px 16px;
                margin-bottom: 4px;
                border-radius: 6px;
                cursor: pointer;
                transition: all 0.2s;
                font-size: 14px;
                color: var(--text-dim);
            }

            .ui-nav-item:hover {
                background: rgba(255, 255, 255, 0.05);
                color: var(--text);
            }

            .ui-nav-item.active {
                background: var(--accent);
                color: #000;
                font-weight: 600;
            }

            .ui-content {
                flex: 1;
                padding: 25px;
                overflow-y: auto;
            }

            .ui-row {
                display: flex;
                align-items: center;
                justify-content: space-between;
                margin-bottom: 15px;
                padding: 12px;
                background: var(--bg-card);
                border-radius: 8px;
                border: 1px solid rgba(255, 255, 255, 0.03);
            }

            .ui-label {
                font-size: 14px;
                color: var(--text-dim);
            }

            .ui-button {
                background: var(--accent);
                color: #000;
                border: none;
                padding: 8px 16px;
                border-radius: 4px;
                font-size: 12px;
                font-weight: 700;
                cursor: pointer;
                text-transform: uppercase;
                transition: transform 0.1s, opacity 0.2s;
            }

            .ui-button:hover {
                opacity: 0.9;
                transform: translateY(-1px);
            }

            .ui-button:active {
                transform: translateY(1px);
            }

            .ui-toggle {
                position: relative;
                display: inline-block;
                width: 44px;
                height: 22px;
            }

            .ui-toggle input {
                opacity: 0;
                width: 0;
                height: 0;
            }

            .ui-slider {
                position: absolute;
                cursor: pointer;
                top: 0;
                left: 0;
                right: 0;
                bottom: 0;
                background-color: #333;
                transition: .4s;
                border-radius: 34px;
            }

            .ui-slider:before {
                position: absolute;
                content: "";
                height: 16px;
                width: 16px;
                left: 3px;
                bottom: 3px;
                background-color: white;
                transition: .4s;
                border-radius: 50%;
            }

            input:checked + .ui-slider {
                background-color: var(--accent);
            }

            input:checked + .ui-slider:before {
                transform: translateX(22px);
                background-color: #000;
            }
        `;
        document.head.appendChild(style);
    },

    createContainer() {
        this.container = document.createElement('div');
        this.container.className = 'ui-overlay';
        document.body.appendChild(this.container);
    },

    setTab(tab) {
        this.settings.activeTab = tab;
        this.render();
    },

    render() {
        this.container.innerHTML = `
            <div class="ui-header">
                <div class="ui-title">System Control</div>
                <div style="font-size: 10px; color: var(--text-dim); opacity: 0.5;">v1.0.4</div>
            </div>
            <div class="ui-body">
                <div class="ui-sidebar">
                    <div class="ui-nav-item ${this.settings.activeTab === 'main' ? 'active' : ''}" onclick="UI.setTab('main')">Dashboard</div>
                    <div class="ui-nav-item ${this.settings.activeTab === 'settings' ? 'active' : ''}" onclick="UI.setTab('settings')">Settings</div>
                    <div class="ui-nav-item ${this.settings.activeTab === 'tools' ? 'active' : ''}" onclick="UI.setTab('tools')">Tools</div>
                </div>
                <div class="ui-content">
                    ${this.renderActiveTab()}
                </div>
            </div>
        `;
    },

    renderActiveTab() {
        if (this.settings.activeTab === 'main') {
            return `
                <div class="ui-row">
                    <span class="ui-label">Fast Execution</span>
                    <label class="ui-toggle">
                        <input type="checkbox" checked>
                        <span class="ui-slider"></span>
                    </label>
                </div>
                <div class="ui-row">
                    <span class="ui-label">Process Visualization</span>
                    <label class="ui-toggle">
                        <input type="checkbox">
                        <span class="ui-slider"></span>
                    </label>
                </div>
                <div class="ui-row">
                    <span class="ui-label">Safe Mode Overlay</span>
                    <button class="ui-button">Activate</button>
                </div>
            `;
        }
        if (this.settings.activeTab === 'settings') {
            return `
                <div class="ui-row">
                    <span class="ui-label">Interface Color</span>
                    <div style="width: 20px; height: 20px; background: var(--accent); border-radius: 50%;"></div>
                </div>
                <div class="ui-row">
                    <span class="ui-label">Auto Updates</span>
                    <label class="ui-toggle">
                        <input type="checkbox" checked>
                        <span class="ui-slider"></span>
                    </label>
                </div>
            `;
        }
        return `<div>No modules active in this section.</div>`;
    }
};

if (typeof document !== 'undefined') {
    UI.init();
}
