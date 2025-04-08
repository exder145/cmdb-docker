/**
 * Copyright (c) OpenSpug Organization. https://github.com/openspug/spug
 * Copyright (c) <spug.dev@gmail.com>
 * Released under the AGPL-3.0 License.
 */
import { observable, computed } from "mobx";
import hostStore from 'pages/host/store';

class Store {
  @observable outputs = {};
  @observable tag = '';
  @observable host_ids = [];
  @observable token = null;
  @observable showConsole = false;
  @observable showTemplate = false;

  @computed get items() {
    const items = Object.entries(this.outputs)
    if (this.tag === '') {
      return items
    } else if (this.tag === '0') {
      return items.filter(([_, x]) => x.status === -2)
    } else if (this.tag === '1') {
      return items.filter(([_, x]) => x.status === 0)
    } else {
      return items.filter(([_, x]) => ![-2, 0].includes(x.status))
    }
  }

  @computed get counter() {
    const counter = {'0': 0, '1': 0, '2': 0}
    for (let item of Object.values(this.outputs)) {
      if (item.status === -2) {
        counter['0'] += 1
      } else if (item.status === 0) {
        counter['1'] += 1
      } else {
        counter['2'] += 1
      }
    }
    return counter
  }

  updateTag = (tag) => {
    if (tag === this.tag) {
      this.tag = ''
    } else {
      this.tag = tag
    }
  }

  switchTemplate = () => {
    this.showTemplate = !this.showTemplate
  };

  switchConsole = (token) => {
    if (this.showConsole) {
      this.showConsole = false;
      this.outputs = {}
      this.token = null;
    } else {
      // 清空之前的输出
      this.outputs = {};
      
      // 设置输出初始状态，使用单一输出容器
      this.outputs['all'] = {
        title: 'Ansible Playbook 执行结果',
        data: '\x1b[36m### 正在准备执行Ansible Playbook...\x1b[0m',
        status: -2
      }
      
      // 记录token以供WebSocket使用
      this.token = token;
      this.showConsole = true
    }
  }
}

export default new Store()
