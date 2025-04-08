/**
 * Copyright (c) OpenSpug Organization. https://github.com/openspug/spug
 * Copyright (c) <spug.dev@gmail.com>
 * Released under the AGPL-3.0 License.
 */
import React, { useState, useEffect } from 'react';
import { Form, Input, Modal, Button, Upload, Avatar, message } from 'antd';
import { PlusOutlined, MinusCircleOutlined } from '@ant-design/icons';
import { http } from 'libs';
import styles from './index.module.less';
import lds from 'lodash';

function NavForm(props) {
  const [form] = Form.useForm();
  const [loading, setLoading] = useState(false);
  const [record, setRecord] = useState(props.record);
  const [fileList, setFileList] = useState([]);

  useEffect(() => {
    if (props.record.logo) {
      setFileList([{uid: 0, thumbUrl: props.record.logo}])
    }
  }, [props.record])

  function handleSubmit() {
    form.validateFields()
      .then(formData => {
        if (formData.id === undefined) {
          formData.sort = 9999
        }
        if (fileList.length > 0) {
          formData.logo = fileList[0].thumbUrl;
        }
        formData.links = record.links.filter(x => x.name && x.url);
        if (formData.links.length === 0) {
          message.error('请至少添加一个导航链接');
          return;
        }
        setLoading(true);
        http.post('/home/navigation/', formData)
          .then(() => {
            message.success('保存成功');
            props.onSubmit()
          })
          .finally(() => setLoading(false))
      })
  }

  function add() {
    if (!record.links) {
      record.links = [];
    }
    record.links.push({name: '', url: ''});
    setRecord(lds.cloneDeep(record))
  }

  function remove(index) {
    record.links.splice(index, 1);
    setRecord(lds.cloneDeep(record))
  }

  function changeLink(e, index, key) {
    if (!record.links) {
      record.links = [];
    }
    if (!record.links[index]) {
      record.links[index] = {};
    }
    record.links[index][key] = e.target.value;
    setRecord(lds.cloneDeep(record))
  }

  function beforeUpload(file) {
    if (file.size / 1024 > 100) {
      message.error('图片将直接存储至数据库，请上传小于100KB的图片');
      setTimeout(() => setFileList([]))
      return false;
    }
    const reader = new FileReader();
    reader.readAsDataURL(file);
    reader.onload = () => {
      setFileList([{
        uid: 0,
        thumbUrl: reader.result
      }]);
    };
    return false;
  }

  if (!record.links) {
    record.links = [{name: '', url: ''}];
  }

  return (
    <Modal
      visible
      title={`${record.id ? '编辑' : '新建'}链接`}
      onCancel={props.onCancel}
      confirmLoading={loading}
      onOk={handleSubmit}>
      <Form form={form} initialValues={record} labelCol={{span: 5}} wrapperCol={{span: 18}}>
        <Form.Item required label="导航图标">
          <Upload
            accept="image/*"
            listType="picture-card"
            fileList={fileList}
            beforeUpload={beforeUpload}
            showUploadList={{showPreviewIcon: false}}
            onChange={({fileList}) => setFileList(fileList)}>
            {fileList.length === 0 && (
              <div>
                <PlusOutlined/>
                <div style={{marginTop: 8}}>点击上传</div>
              </div>
            )}
          </Upload>
          <div className={styles.imgExample}>
            {['gitlab', 'gitee', 'grafana', 'prometheus', 'wiki'].map(item => (
              <Avatar
                key={item}
                src={`/resource/${item}.png`}
                onClick={() => setFileList([{uid: 0, thumbUrl: `/resource/${item}.png`}])}/>
            ))}
          </div>
        </Form.Item>
        <Form.Item required name="title" label="导航标题">
          <Input placeholder="请输入"/>
        </Form.Item>
        <Form.Item required name="desc" label="导航描述">
          <Input placeholder="请输入"/>
        </Form.Item>
        <Form.Item required label="导航链接" style={{marginBottom: 0}}>
          {record.links.map((item, index) => (
            <div key={index} style={{display: 'flex', alignItems: 'center', marginBottom: 12}}>
              <Form.Item style={{display: 'inline-block', margin: 0, width: 100}}>
                <Input value={item.name} onChange={e => changeLink(e, index, 'name')} placeholder="链接名称"/>
              </Form.Item>
              <Form.Item style={{display: 'inline-block', width: 210, margin: '0 8px'}}>
                <Input value={item.url} onChange={e => changeLink(e, index, 'url')} placeholder="请输入链接地址"/>
              </Form.Item>
              {record.links.length > 1 && (
                <MinusCircleOutlined className={styles.minusIcon} onClick={() => remove(index)}/>
              )}
            </div>
          ))}
        </Form.Item>
        <Form.Item wrapperCol={{span: 18, offset: 5}}>
          <Button type="dashed" onClick={add} style={{width: 318}} icon={<PlusOutlined/>}>
            添加链接（推荐最多三个）
          </Button>
        </Form.Item>
      </Form>
    </Modal>
  )
}

export default NavForm
