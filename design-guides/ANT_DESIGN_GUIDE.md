# 🐜 Ant Design Professional Guide
**Enterprise-Ready Components for Data-Heavy Applications**

## 🚀 Why Ant Design?
- **Enterprise Focus**: Built for business applications and admin panels
- **Rich Component Library**: 60+ high-quality React components
- **Data Management**: Excellent tables, forms, and data visualization
- **Design Language**: Consistent, professional design system
- **TypeScript**: First-class TypeScript support
- **Internationalization**: Built-in i18n support

---

## ⚡ Quick Setup & Configuration

### 1. Installation
```bash
npm install antd
# For icons (optional but recommended)
npm install @ant-design/icons
```

### 2. Basic Setup
```jsx
// App.js
import React from 'react';
import { ConfigProvider } from 'antd';
import 'antd/dist/reset.css'; // v5.x
// import 'antd/dist/antd.css'; // v4.x

const App = () => {
  return (
    <ConfigProvider
      theme={{
        token: {
          colorPrimary: '#1890ff',
          borderRadius: 8,
        },
      }}
    >
      {/* Your app content */}
    </ConfigProvider>
  );
};
```

### 3. Custom Theme Configuration
```jsx
import { ConfigProvider, theme } from 'antd';

const customTheme = {
  token: {
    // Seed Token
    colorPrimary: '#1890ff',
    borderRadius: 8,
    
    // Alias Token
    colorBgContainer: '#f6ffed',
    
    // Component Token
    Button: {
      colorPrimary: '#00b96b',
    },
  },
  algorithm: theme.darkAlgorithm, // Enable dark mode
};

<ConfigProvider theme={customTheme}>
  <App />
</ConfigProvider>
```

---

## 📊 Professional Dashboard Components

### 📈 Advanced Data Dashboard
```jsx
import React, { useState } from 'react';
import {
  Card,
  Row,
  Col,
  Statistic,
  Table,
  DatePicker,
  Select,
  Button,
  Space,
  Progress,
  Badge,
  Avatar,
  Typography,
} from 'antd';
import {
  ArrowUpOutlined,
  ArrowDownOutlined,
  UserOutlined,
  ShoppingCartOutlined,
  DollarOutlined,
  EyeOutlined,
} from '@ant-design/icons';

const { RangePicker } = DatePicker;
const { Option } = Select;
const { Title, Text } = Typography;

const DashboardStats = () => {
  const [dateRange, setDateRange] = useState(null);
  const [selectedMetric, setSelectedMetric] = useState('revenue');

  const statsData = [
    {
      title: 'Total Revenue',
      value: 112893,
      precision: 2,
      valueStyle: { color: '#3f8600' },
      prefix: '$',
      suffix: <ArrowUpOutlined />,
      loading: false,
    },
    {
      title: 'Active Users',
      value: 2847,
      valueStyle: { color: '#1890ff' },
      prefix: <UserOutlined />,
      suffix: <ArrowUpOutlined />,
    },
    {
      title: 'Orders',
      value: 1238,
      valueStyle: { color: '#722ed1' },
      prefix: <ShoppingCartOutlined />,
      suffix: <ArrowDownOutlined />,
    },
    {
      title: 'Conversion Rate',
      value: 3.47,
      precision: 2,
      valueStyle: { color: '#cf1322' },
      suffix: '%',
    },
  ];

  return (
    <div style={{ padding: '24px', background: '#f0f2f5', minHeight: '100vh' }}>
      {/* Header */}
      <div style={{ marginBottom: '24px' }}>
        <Title level={2}>Analytics Dashboard</Title>
        <Space size="large">
          <RangePicker onChange={setDateRange} />
          <Select
            defaultValue="revenue"
            style={{ width: 120 }}
            onChange={setSelectedMetric}
          >
            <Option value="revenue">Revenue</Option>
            <Option value="users">Users</Option>
            <Option value="orders">Orders</Option>
          </Select>
          <Button type="primary" icon={<EyeOutlined />}>
            View Report
          </Button>
        </Space>
      </div>

      {/* Stats Cards */}
      <Row gutter={[16, 16]} style={{ marginBottom: '24px' }}>
        {statsData.map((stat, index) => (
          <Col xs={24} sm={12} lg={6} key={index}>
            <Card>
              <Statistic
                title={stat.title}
                value={stat.value}
                precision={stat.precision}
                valueStyle={stat.valueStyle}
                prefix={stat.prefix}
                suffix={stat.suffix}
                loading={stat.loading}
              />
            </Card>
          </Col>
        ))}
      </Row>

      {/* Performance Metrics */}
      <Row gutter={[16, 16]}>
        <Col xs={24} lg={16}>
          <Card title="Sales Performance" bordered={false}>
            <UserDataTable />
          </Card>
        </Col>
        <Col xs={24} lg={8}>
          <Card title="Team Progress" bordered={false}>
            <TeamProgressCard />
          </Card>
        </Col>
      </Row>
    </div>
  );
};

const TeamProgressCard = () => {
  const teamData = [
    { name: 'Development', progress: 85, status: 'success' },
    { name: 'Design', progress: 67, status: 'normal' },
    { name: 'Marketing', progress: 92, status: 'success' },
    { name: 'QA Testing', progress: 45, status: 'exception' },
  ];

  return (
    <Space direction="vertical" style={{ width: '100%' }} size="large">
      {teamData.map((team, index) => (
        <div key={index}>
          <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '8px' }}>
            <Text strong>{team.name}</Text>
            <Text>{team.progress}%</Text>
          </div>
          <Progress
            percent={team.progress}
            status={team.status}
            strokeWidth={8}
            showInfo={false}
          />
        </div>
      ))}
    </Space>
  );
};
```

### 📋 Advanced Data Table
```jsx
import React, { useState, useMemo } from 'react';
import {
  Table,
  Space,
  Button,
  Tag,
  Avatar,
  Dropdown,
  Menu,
  Input,
  DatePicker,
  Select,
  Badge,
  Tooltip,
  Typography,
} from 'antd';
import {
  MoreOutlined,
  SearchOutlined,
  FilterOutlined,
  ExportOutlined,
  EditOutlined,
  DeleteOutlined,
  EyeOutlined,
} from '@ant-design/icons';

const { Search } = Input;
const { Option } = Select;
const { Text } = Typography;

const UserDataTable = () => {
  const [searchText, setSearchText] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');
  const [selectedRowKeys, setSelectedRowKeys] = useState([]);
  const [loading, setLoading] = useState(false);

  const mockData = [
    {
      key: '1',
      id: 'USR-001',
      name: 'John Smith',
      email: 'john.smith@company.com',
      role: 'Senior Developer',
      department: 'Engineering',
      status: 'active',
      lastLogin: '2024-01-15 14:30',
      avatar: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80',
      performance: 92,
    },
    {
      key: '2',
      id: 'USR-002',
      name: 'Sarah Johnson',
      email: 'sarah.j@company.com',
      role: 'UX Designer',
      department: 'Design',
      status: 'active',
      lastLogin: '2024-01-15 12:45',
      avatar: 'https://images.unsplash.com/photo-1494790108755-2616b612b786?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80',
      performance: 88,
    },
    {
      key: '3',
      id: 'USR-003',
      name: 'Mike Chen',
      email: 'mike.chen@company.com',
      role: 'Product Manager',
      department: 'Product',
      status: 'pending',
      lastLogin: '2024-01-14 16:20',
      avatar: null,
      performance: 75,
    },
    {
      key: '4',
      id: 'USR-004',
      name: 'Emily Davis',
      email: 'emily.davis@company.com',
      role: 'Marketing Lead',
      department: 'Marketing',
      status: 'inactive',
      lastLogin: '2024-01-10 09:15',
      avatar: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80',
      performance: 95,
    },
  ];

  // Row selection configuration
  const rowSelection = {
    selectedRowKeys,
    onChange: setSelectedRowKeys,
    getCheckboxProps: (record) => ({
      disabled: record.status === 'inactive',
    }),
  };

  // Action menu
  const getActionMenu = (record) => (
    <Menu>
      <Menu.Item key="view" icon={<EyeOutlined />}>
        View Profile
      </Menu.Item>
      <Menu.Item key="edit" icon={<EditOutlined />}>
        Edit User
      </Menu.Item>
      <Menu.Divider />
      <Menu.Item key="delete" icon={<DeleteOutlined />} danger>
        Delete User
      </Menu.Item>
    </Menu>
  );

  // Table columns
  const columns = [
    {
      title: 'User',
      dataIndex: 'name',
      key: 'name',
      fixed: 'left',
      width: 250,
      render: (text, record) => (
        <Space>
          <Avatar 
            src={record.avatar} 
            icon={<UserOutlined />}
            size={40}
          />
          <div>
            <div>
              <Text strong>{text}</Text>
              <Badge 
                count={record.performance > 90 ? 'Top' : null} 
                style={{ backgroundColor: '#52c41a', marginLeft: 8 }}
              />
            </div>
            <Text type="secondary" style={{ fontSize: '12px' }}>
              {record.email}
            </Text>
          </div>
        </Space>
      ),
      sorter: (a, b) => a.name.localeCompare(b.name),
      filterable: true,
    },
    {
      title: 'Role & Department',
      dataIndex: 'role',
      key: 'role',
      width: 200,
      render: (text, record) => (
        <div>
          <Text strong>{text}</Text>
          <br />
          <Tag color="blue">{record.department}</Tag>
        </div>
      ),
      filters: [
        { text: 'Engineering', value: 'Engineering' },
        { text: 'Design', value: 'Design' },
        { text: 'Product', value: 'Product' },
        { text: 'Marketing', value: 'Marketing' },
      ],
      onFilter: (value, record) => record.department === value,
    },
    {
      title: 'Status',
      dataIndex: 'status',
      key: 'status',
      width: 120,
      render: (status) => {
        const colorMap = {
          active: 'success',
          pending: 'warning',
          inactive: 'default',
        };
        const textMap = {
          active: 'Active',
          pending: 'Pending',
          inactive: 'Inactive',
        };
        return (
          <Badge 
            status={colorMap[status]} 
            text={textMap[status]}
          />
        );
      },
      filters: [
        { text: 'Active', value: 'active' },
        { text: 'Pending', value: 'pending' },
        { text: 'Inactive', value: 'inactive' },
      ],
      onFilter: (value, record) => record.status === value,
    },
    {
      title: 'Performance',
      dataIndex: 'performance',
      key: 'performance',
      width: 150,
      render: (value) => (
        <div>
          <Text>{value}%</Text>
          <Progress
            percent={value}
            size="small"
            strokeColor={value > 90 ? '#52c41a' : value > 70 ? '#1890ff' : '#faad14'}
            showInfo={false}
            style={{ marginTop: 4 }}
          />
        </div>
      ),
      sorter: (a, b) => a.performance - b.performance,
    },
    {
      title: 'Last Login',
      dataIndex: 'lastLogin',
      key: 'lastLogin',
      width: 150,
      render: (text) => (
        <Tooltip title="Last activity time">
          <Text type="secondary">{text}</Text>
        </Tooltip>
      ),
      sorter: (a, b) => new Date(a.lastLogin) - new Date(b.lastLogin),
    },
    {
      title: 'Actions',
      key: 'actions',
      fixed: 'right',
      width: 80,
      render: (_, record) => (
        <Dropdown overlay={getActionMenu(record)} trigger={['click']}>
          <Button type="text" icon={<MoreOutlined />} />
        </Dropdown>
      ),
    },
  ];

  // Filter data based on search and status
  const filteredData = useMemo(() => {
    return mockData.filter(item => {
      const matchesSearch = item.name.toLowerCase().includes(searchText.toLowerCase()) ||
                           item.email.toLowerCase().includes(searchText.toLowerCase());
      const matchesStatus = statusFilter === 'all' || item.status === statusFilter;
      return matchesSearch && matchesStatus;
    });
  }, [searchText, statusFilter, mockData]);

  return (
    <div>
      {/* Toolbar */}
      <div style={{ 
        marginBottom: 16, 
        display: 'flex', 
        justifyContent: 'space-between',
        alignItems: 'center',
        flexWrap: 'wrap',
        gap: 16
      }}>
        <Space size="middle">
          <Search
            placeholder="Search users..."
            allowClear
            style={{ width: 300 }}
            onSearch={setSearchText}
            onChange={(e) => setSearchText(e.target.value)}
          />
          <Select
            value={statusFilter}
            style={{ width: 120 }}
            onChange={setStatusFilter}
          >
            <Option value="all">All Status</Option>
            <Option value="active">Active</Option>
            <Option value="pending">Pending</Option>
            <Option value="inactive">Inactive</Option>
          </Select>
        </Space>
        
        <Space>
          <Button icon={<FilterOutlined />}>
            Advanced Filter
          </Button>
          <Button icon={<ExportOutlined />}>
            Export
          </Button>
          <Button type="primary">
            Add User
          </Button>
        </Space>
      </div>

      {/* Bulk Actions */}
      {selectedRowKeys.length > 0 && (
        <div style={{ 
          marginBottom: 16, 
          padding: 12, 
          backgroundColor: '#e6f7ff', 
          borderRadius: 6,
          border: '1px solid #91d5ff'
        }}>
          <Space>
            <Text strong>{selectedRowKeys.length} item(s) selected</Text>
            <Button size="small">Bulk Edit</Button>
            <Button size="small" danger>Bulk Delete</Button>
          </Space>
        </div>
      )}

      {/* Table */}
      <Table
        columns={columns}
        dataSource={filteredData}
        rowSelection={rowSelection}
        loading={loading}
        pagination={{
          total: filteredData.length,
          pageSize: 10,
          showSizeChanger: true,
          showQuickJumper: true,
          showTotal: (total, range) => 
            `${range[0]}-${range[1]} of ${total} items`,
        }}
        scroll={{ x: 1200 }}
        size="middle"
        bordered={false}
        style={{
          backgroundColor: 'white',
          borderRadius: 8,
        }}
      />
    </div>
  );
};

export default UserDataTable;
```

### 📝 Advanced Form Components
```jsx
import React, { useState } from 'react';
import {
  Form,
  Input,
  Select,
  DatePicker,
  InputNumber,
  Switch,
  Upload,
  Button,
  Card,
  Divider,
  Space,
  Row,
  Col,
  message,
  Steps,
  Typography,
} from 'antd';
import {
  InboxOutlined,
  UserOutlined,
  MailOutlined,
  PhoneOutlined,
  SaveOutlined,
} from '@ant-design/icons';

const { Option } = Select;
const { TextArea } = Input;
const { Dragger } = Upload;
const { Title } = Typography;
const { Step } = Steps;

const AdvancedUserForm = () => {
  const [form] = Form.useForm();
  const [currentStep, setCurrentStep] = useState(0);
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState({});

  const steps = [
    {
      title: 'Basic Information',
      content: 'basic',
    },
    {
      title: 'Contact Details',
      content: 'contact',
    },
    {
      title: 'Preferences',
      content: 'preferences',
    },
    {
      title: 'Review',
      content: 'review',
    },
  ];

  const uploadProps = {
    name: 'file',
    multiple: true,
    action: 'https://www.mocky.io/v2/5cc8019d300000980a055e76',
    onChange(info) {
      const { status } = info.file;
      if (status !== 'uploading') {
        console.log(info.file, info.fileList);
      }
      if (status === 'done') {
        message.success(`${info.file.name} file uploaded successfully.`);
      } else if (status === 'error') {
        message.error(`${info.file.name} file upload failed.`);
      }
    },
  };

  const onFinish = async (values) => {
    setLoading(true);
    try {
      // Simulate API call
      await new Promise(resolve => setTimeout(resolve, 2000));
      message.success('User created successfully!');
      form.resetFields();
      setCurrentStep(0);
    } catch (error) {
      message.error('Failed to create user. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const nextStep = () => {
    form.validateFields().then(values => {
      setFormData({ ...formData, ...values });
      setCurrentStep(currentStep + 1);
    });
  };

  const prevStep = () => {
    setCurrentStep(currentStep - 1);
  };

  const renderStepContent = () => {
    switch (currentStep) {
      case 0:
        return (
          <Row gutter={[16, 16]}>
            <Col xs={24} md={12}>
              <Form.Item
                label="First Name"
                name="firstName"
                rules={[{ required: true, message: 'Please enter first name' }]}
              >
                <Input 
                  prefix={<UserOutlined />} 
                  placeholder="John" 
                  size="large"
                />
              </Form.Item>
            </Col>
            <Col xs={24} md={12}>
              <Form.Item
                label="Last Name"
                name="lastName"
                rules={[{ required: true, message: 'Please enter last name' }]}
              >
                <Input 
                  prefix={<UserOutlined />} 
                  placeholder="Smith" 
                  size="large"
                />
              </Form.Item>
            </Col>
            <Col xs={24} md={12}>
              <Form.Item
                label="Date of Birth"
                name="dateOfBirth"
                rules={[{ required: true, message: 'Please select date of birth' }]}
              >
                <DatePicker 
                  style={{ width: '100%' }} 
                  size="large"
                  placeholder="Select date"
                />
              </Form.Item>
            </Col>
            <Col xs={24} md={12}>
              <Form.Item
                label="Gender"
                name="gender"
                rules={[{ required: true, message: 'Please select gender' }]}
              >
                <Select size="large" placeholder="Select gender">
                  <Option value="male">Male</Option>
                  <Option value="female">Female</Option>
                  <Option value="other">Other</Option>
                  <Option value="prefer-not-to-say">Prefer not to say</Option>
                </Select>
              </Form.Item>
            </Col>
            <Col xs={24}>
              <Form.Item
                label="Profile Picture"
                name="avatar"
              >
                <Dragger {...uploadProps} style={{ padding: '20px' }}>
                  <p className="ant-upload-drag-icon">
                    <InboxOutlined />
                  </p>
                  <p className="ant-upload-text">Click or drag file to this area to upload</p>
                  <p className="ant-upload-hint">
                    Support for single upload. Strictly prohibit from uploading company data.
                  </p>
                </Dragger>
              </Form.Item>
            </Col>
          </Row>
        );
      
      case 1:
        return (
          <Row gutter={[16, 16]}>
            <Col xs={24} md={12}>
              <Form.Item
                label="Email"
                name="email"
                rules={[
                  { required: true, message: 'Please enter email' },
                  { type: 'email', message: 'Please enter a valid email' }
                ]}
              >
                <Input 
                  prefix={<MailOutlined />} 
                  placeholder="john.smith@company.com" 
                  size="large"
                />
              </Form.Item>
            </Col>
            <Col xs={24} md={12}>
              <Form.Item
                label="Phone Number"
                name="phone"
                rules={[{ required: true, message: 'Please enter phone number' }]}
              >
                <Input 
                  prefix={<PhoneOutlined />} 
                  placeholder="+1 (555) 123-4567" 
                  size="large"
                />
              </Form.Item>
            </Col>
            <Col xs={24}>
              <Form.Item
                label="Address"
                name="address"
                rules={[{ required: true, message: 'Please enter address' }]}
              >
                <TextArea 
                  rows={3} 
                  placeholder="Enter full address"
                  style={{ resize: 'none' }}
                />
              </Form.Item>
            </Col>
            <Col xs={24} md={12}>
              <Form.Item
                label="City"
                name="city"
                rules={[{ required: true, message: 'Please enter city' }]}
              >
                <Input size="large" placeholder="New York" />
              </Form.Item>
            </Col>
            <Col xs={24} md={12}>
              <Form.Item
                label="Postal Code"
                name="postalCode"
                rules={[{ required: true, message: 'Please enter postal code' }]}
              >
                <Input size="large" placeholder="10001" />
              </Form.Item>
            </Col>
          </Row>
        );
      
      case 2:
        return (
          <Row gutter={[16, 16]}>
            <Col xs={24} md={12}>
              <Form.Item
                label="Department"
                name="department"
                rules={[{ required: true, message: 'Please select department' }]}
              >
                <Select size="large" placeholder="Select department">
                  <Option value="engineering">Engineering</Option>
                  <Option value="design">Design</Option>
                  <Option value="product">Product</Option>
                  <Option value="marketing">Marketing</Option>
                  <Option value="sales">Sales</Option>
                </Select>
              </Form.Item>
            </Col>
            <Col xs={24} md={12}>
              <Form.Item
                label="Role"
                name="role"
                rules={[{ required: true, message: 'Please enter role' }]}
              >
                <Input size="large" placeholder="Senior Developer" />
              </Form.Item>
            </Col>
            <Col xs={24} md={12}>
              <Form.Item
                label="Salary"
                name="salary"
                rules={[{ required: true, message: 'Please enter salary' }]}
              >
                <InputNumber
                  size="large"
                  style={{ width: '100%' }}
                  formatter={value => `$ ${value}`.replace(/\B(?=(\d{3})+(?!\d))/g, ',')}
                  parser={value => value.replace(/\$\s?|(,*)/g, '')}
                  placeholder="75000"
                />
              </Form.Item>
            </Col>
            <Col xs={24} md={12}>
              <Form.Item
                label="Start Date"
                name="startDate"
                rules={[{ required: true, message: 'Please select start date' }]}
              >
                <DatePicker 
                  style={{ width: '100%' }} 
                  size="large"
                  placeholder="Select start date"
                />
              </Form.Item>
            </Col>
            <Col xs={24}>
              <Form.Item
                label="Email Notifications"
                name="emailNotifications"
                valuePropName="checked"
              >
                <Switch />
              </Form.Item>
            </Col>
            <Col xs={24}>
              <Form.Item
                label="Notes"
                name="notes"
              >
                <TextArea 
                  rows={4} 
                  placeholder="Additional notes about the employee..."
                  style={{ resize: 'none' }}
                />
              </Form.Item>
            </Col>
          </Row>
        );
      
      case 3:
        return (
          <div style={{ textAlign: 'center', padding: '40px 0' }}>
            <Title level={3}>Review Your Information</Title>
            <p>Please review all the information before submitting.</p>
            {/* Add review content here */}
          </div>
        );
      
      default:
        return null;
    }
  };

  return (
    <Card 
      style={{ 
        maxWidth: 800, 
        margin: '0 auto',
        boxShadow: '0 4px 12px rgba(0,0,0,0.15)'
      }}
    >
      <Title level={2} style={{ textAlign: 'center', marginBottom: 30 }}>
        New Employee Registration
      </Title>
      
      <Steps current={currentStep} style={{ marginBottom: 30 }}>
        {steps.map((item, index) => (
          <Step key={index} title={item.title} />
        ))}
      </Steps>
      
      <Form
        form={form}
        layout="vertical"
        onFinish={onFinish}
        initialValues={{
          emailNotifications: true,
        }}
      >
        {renderStepContent()}
        
        <Divider />
        
        <div style={{ textAlign: 'right' }}>
          <Space>
            {currentStep > 0 && (
              <Button onClick={prevStep}>
                Previous
              </Button>
            )}
            {currentStep < steps.length - 1 ? (
              <Button type="primary" onClick={nextStep}>
                Next
              </Button>
            ) : (
              <Button 
                type="primary" 
                htmlType="submit" 
                loading={loading}
                icon={<SaveOutlined />}
              >
                Create Employee
              </Button>
            )}
          </Space>
        </div>
      </Form>
    </Card>
  );
};

export default AdvancedUserForm;
```

---

## 🎨 Custom Theme & Styling

### 🌈 Advanced Theme Configuration
```jsx
import { ConfigProvider, theme } from 'antd';

const customTheme = {
  token: {
    // Primary colors
    colorPrimary: '#1890ff',
    colorSuccess: '#52c41a',
    colorWarning: '#faad14',
    colorError: '#ff4d4f',
    colorInfo: '#1890ff',
    
    // Layout
    borderRadius: 8,
    wireframe: false,
    
    // Typography
    fontSize: 14,
    fontFamily: `-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif`,
    
    // Spacing
    sizeUnit: 4,
    sizeStep: 4,
    
    // Motion
    motionDurationFast: '0.1s',
    motionDurationMid: '0.2s',
    motionDurationSlow: '0.3s',
  },
  components: {
    Button: {
      borderRadius: 6,
      controlHeight: 40,
    },
    Input: {
      borderRadius: 6,
      controlHeight: 40,
    },
    Card: {
      borderRadius: 12,
      headerBg: '#fafafa',
    },
    Table: {
      borderRadius: 8,
      headerBg: '#f5f5f5',
    },
  },
};

// Usage
<ConfigProvider theme={customTheme}>
  <App />
</ConfigProvider>
```

### 🎭 Dark Mode Support
```jsx
import { ConfigProvider, theme, Switch } from 'antd';
import { useState } from 'react';

const App = () => {
  const [darkMode, setDarkMode] = useState(false);
  
  const themeConfig = {
    algorithm: darkMode ? theme.darkAlgorithm : theme.defaultAlgorithm,
    token: {
      colorPrimary: '#1890ff',
    },
  };
  
  return (
    <ConfigProvider theme={themeConfig}>
      <div style={{ padding: 20 }}>
        <Switch 
          checked={darkMode} 
          onChange={setDarkMode}
          checkedChildren="🌙" 
          unCheckedChildren="☀️"
        />
        {/* Your app content */}
      </div>
    </ConfigProvider>
  );
};
```

---

## 🚀 Performance Best Practices

### 📦 Tree Shaking
```jsx
// ✅ Good: Import specific components
import { Button, Card, Table } from 'antd';

// ❌ Avoid: Importing entire library
import * as antd from 'antd';
```

### 🎯 Bundle Optimization
```js
// webpack.config.js
module.exports = {
  resolve: {
    alias: {
      '@ant-design/icons': '@ant-design/icons/es/icons'
    }
  }
};

// Or use babel plugin
// .babelrc
{
  "plugins": [
    ["import", {
      "libraryName": "antd",
      "libraryDirectory": "es",
      "style": "css"
    }]
  ]
}
```

---

## 🔗 Resources & Extensions

- **Ant Design Documentation**: [ant.design](https://ant.design)
- **Pro Components**: [procomponents.ant.design](https://procomponents.ant.design)
- **Ant Design Charts**: [charts.ant.design](https://charts.ant.design)
- **Icon Library**: [@ant-design/icons](https://ant.design/components/icon/)
- **Mobile Components**: [mobile.ant.design](https://mobile.ant.design)

**Next: Build enterprise-grade applications with these professional components!**